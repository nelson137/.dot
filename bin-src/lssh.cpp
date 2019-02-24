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


void puterr(string const& str="") {
    cerr << str << endl;
}


void print_config_help() {
    puterr("The config file must be valid JSON with the following structure:");
    puterr();
    puterr("{");
    puterr("    \"profiles\": [");
    puterr("        {");
    puterr("            \"name\": \"<name>\",");
    puterr("            \"username\": \"<username>\",");
    puterr("            \"hosts\": [\"example.com\", \"1.2.3.4\", ...]");
    puterr("        },");
    puterr("        ...");
    puterr("    ]");
    puterr("}");
    puterr();
    puterr("A profile name, username, and list of at least one host ");
    puterr("must be specified for each host.");
}


/*************************************************
 * Profile Class
 ************************************************/


class Profile {

public:
    string name;
    string user;
    vector<string> hosts;

    Profile(json::iterator&);

};


Profile::Profile(json::iterator& it) {
    auto value = it.value();
    this->name = value["name"];
    this->user = value["username"];
    json hosts = value["hosts"];
    for (auto&& it=hosts.begin(); it!=hosts.end(); it++)
        this->hosts.push_back(it.value());
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

    if (value.find("name") == value.end())
        this->config_error("Profiles must specify a name");
    if (!value["name"].is_string())
        this->config_error("Profile names must be of type string");

    if (value.find("username") == value.end())
        this->config_error("Profiles must specify a username");
    if (!value["username"].is_string())
        this->config_error("Profile usernames must be of type string");

    if (value.find("hosts") == value.end())
        this->config_error("Profiles must specify an array of hosts");
    if (!value["hosts"].is_array())
        this->config_error("Profile hosts must be an array of strings");
}


void Config::read_config() {
    char *home = getenv("HOME");
    if (home == NULL)
        die("Environment variable $HOME is not set");

    if (!file_exists(this->config_fn))
        die("Config file does not exist:", config_fn);

    ifstream fs;
    fs.open(this->config_fn);

    json config;
    fs >> config;

    json j_profiles = config["profiles"];

    if (j_profiles.is_null())
        this->config_error("Config must specify an array of profiles");
    if (!j_profiles.is_array())
        this->config_error("Config profiles object must be an array");

    this->profiles.reserve(j_profiles.size());

    for (auto&& it=j_profiles.begin(); it!=j_profiles.end(); it++) {
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

    if (profile.hosts.size() == 1) {
        addr += profile.hosts[0];
    } else {
        int addr_i = Listbox(profile.hosts).run();
        cout << endl;
        if (addr_i < 0)
            die();
        addr += profile.hosts[addr_i];
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
