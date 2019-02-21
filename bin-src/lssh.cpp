#include <iostream>
#include <fstream>

#include <nlohmann/json.hpp>

#include <unistd.h>
#include <wait.h>
#include <pwd.h>

#include "mylib++.hpp"

using namespace std;
using namespace nlohmann;


/*************************************************
 * Helper Functions
 ************************************************/


void print_config_help() {
    cerr << "The config file must be valid JSON with the following "
         << "structure:" << endl;
    cerr << "    {" << endl;
    cerr << "      \"<hostname>\": {" << endl;
    cerr << "        \"username\": \"<username>\"," << endl;
    cerr << "        \"internal_addr\": \"<internal ip addr>\"," << endl;
    cerr << "        \"external_addr\": \"<external ip addr>\"" << endl;
    cerr << "      }," << endl;
    cerr << "      ..." << endl;
    cerr << "    }" << endl;
    cerr << "A username must be specified for each host." << endl;
    cerr << "Both an internal and external ip address do not have to be "
         << "specified," << endl;
    cerr << "but at least one must." << endl;
}


/*************************************************
 * Profile Class
 ************************************************/


class Profile {

public:
    string name;
    string user;
    string internal_addr;
    string external_addr;

    Profile(json::iterator&);

    bool has_internal_addr();
    bool has_external_addr();

};


Profile::Profile(json::iterator& it) {
    auto value = it.value();
    this->name = it.key();
    this->user = value["username"];
    this->internal_addr = value["internal_addr"];
    this->external_addr = value["external_addr"];
}


bool Profile::has_internal_addr() {
    return this->internal_addr.size();
}


bool Profile::has_external_addr() {
    return this->external_addr.size();
}


/*************************************************
 * Config Class
 ************************************************/


class Config {

private:
    string config_fn;

    template<typename... T> void config_error(T...);
    string get_home_dir();
    void profile_is_valid(json::iterator&);
    void read_config();

public:
    vector<Profile> profiles;

    Config(string&);

    vector<string> get_profile_names();

};


template<typename... T>
void Config::config_error(T... ts) {
    cerr << "Error in config file: " << this->config_fn << endl;
    die(ts...);
}


void Config::profile_is_valid(json::iterator& it) {
    auto value = it.value();

    if (value.find("username") == value.end())
        this->config_error("Profiles must specify a username");
    if (!value["username"].is_string())
        this->config_error("Profile usernames must be of type string");

    if (value.find("internal_addr") == value.end() &&
            value.find("internal_addr") == value.end())
        this->config_error(
            "Profiles must specify at least an internal or external address");
    if (!value["internal_addr"].is_string())
        this->config_error("Profile internal_addrs must be of type string");

    if (!value["external_addr"].is_string())
        this->config_error("Profile external_addrs must be of type string");
    if (!value["external_addr"].is_string())
        this->config_error("Profile external_addrs must be of type string");
}


void Config::read_config() {
    char *home = getenv("HOME");
    if (home == NULL)
        die("Environment variable $HOME is not set");

    string config_fn = string(home) + "/.lsshrc";

    if (!file_exists(config_fn))
        die("Config file does not exist:", config_fn);

    ifstream fs;
    fs.open(config_fn);

    json config;
    fs >> config;

    if (!config.size())
        die("No profiles found in config file:", config_fn);

    this->profiles.reserve(config.size());

    for (auto&& it=config.begin(); it!=config.end(); it++) {
        this->profile_is_valid(it);
        this->profiles.push_back(Profile(it));
    }
}


Config::Config(string& fn) {
    this->config_fn = fn;
    this->read_config();
}


vector<string> Config::get_profile_names() {
    vector<string> names;
    names.reserve(this->profiles.size());
    for (auto& p : this->profiles)
        names.push_back(p.name);
    return names;
}


/*************************************************
 * Core Functions
 ************************************************/


string get_home_dir() {
    string home = string(getenv("HOME"));
    if (home.size())
        return home;

    struct passwd *pd = getpwuid(getuid());
    if (pd != NULL)
        return string(pd->pw_dir);

    die("Home directory of user could not be determined");

    // Suppress control reaches end of non-void function error
    return "";
}


string select_profile(Config& config) {
    cout << endl;
    vector<string> profile_names = config.get_profile_names();
    int profile_i = Listbox(profile_names).run();
    cout << endl;
    if (profile_i < 0)
        die();

    Profile& profile = config.profiles[profile_i];
    string addr = profile.user + '@';

    if (!profile.has_internal_addr()) {
        addr += profile.external_addr;
    } else if (!profile.has_external_addr()) {
        addr += profile.internal_addr;
    } else {
        vector<string> addrs = {profile.internal_addr, profile.external_addr};
        int addr_i = Listbox(addrs).run();
        cout << endl;
        if (addr_i < 0)
            die();
        addr += addrs[addr_i];
    }

    return addr;
}


void attempt_ssh(string const& addr) {
    int stat, pid = fork();
    if (pid < 0) {
        die("Could not fork()");
    } else if (pid == 0) {
        // Child
        execl("/usr/bin/ssh", "ssh", "-oConnectTimeout=5", addr.c_str(), NULL);
        _exit(127);
    } else {
        // Parent
        wait(&stat);
    }
}


/*************************************************
 * Main
 ************************************************/


int main() {
    string config_fn = get_home_dir() + "/.lsshrc";
    Config config(config_fn);

    string addr = select_profile(config);
    attempt_ssh(addr);

    return 0;
}
