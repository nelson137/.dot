#include <iostream>
#include <fstream>

#include <nlohmann/json.hpp>

#include <string.h>
#include <unistd.h>
#include <wait.h>
#include <pwd.h>

#include "mylib++.hpp"

using namespace std;
using namespace nlohmann;

namespace profile {}
using namespace profile;


/*************************************************
 * Helper Functions
 ************************************************/


void puterr(string const& str="") {
    cerr << str << endl;
}


void print_config_help() {
    puterr("The config file is a JSON file with the following structure:");
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
    puterr("A profile name, username, and list of at least one host must be");
    puterr("specified for each host.");
}


/*************************************************
 * Classes
 ************************************************/


namespace profile {

struct Profile {

    string name;
    string user;
    vector<string> hosts;
    string keyfile;

    static void validate_data(const json&);

};

void from_json(const json& j, Profile& p) {
    Profile::validate_data(j);

    p.name = j["name"];

    p.user = j["username"];

    json j_hosts = j["hosts"];
    for (auto&& it=j_hosts.begin(); it!=j_hosts.end(); it++)
        p.hosts.push_back(it.value());

    if (j.find("keyfile") != j.end())
        p.keyfile = j["keyfile"].get<string>();
}

}  // namespace profile


class Config {

private:
    string config_fn;

    json get_config();

    void parse_config(json);

public:
    vector<Profile> profiles;
    vector<string> ssh_opts;

    template<typename... T>
        static void error(T...);

    Config(string&);

    vector<string> get_profile_names();

};


/*************************************************
 * JSON Helper Functions
 ************************************************/


template<typename U>
vector<U> parse_array(string key, json& j_arr) {
    if (!j_arr.is_array())
        Config::error("Value for key '"+key+"' must be of type 'array'");
    vector<U> arr(j_arr.size());
    transform(j_arr.begin(), j_arr.end(), arr.begin(),
        [](json j){ return j.get<U>(); });
    return arr;
}


/*************************************************
 * Profile Methods
 ************************************************/


void Profile::validate_data(const json& j_profile) {
    if (j_profile.find("name") == j_profile.end())
        Config::error("Profiles must specify a name");
    if (!j_profile["name"].is_string())
        Config::error("Profile names must be of type string");

    if (j_profile.find("username") == j_profile.end())
        Config::error("Profiles must specify a username");
    if (!j_profile["username"].is_string())
        Config::error("Profile usernames must be of type string");

    if (j_profile.find("hosts") == j_profile.end())
        Config::error("Profiles must specify an array of hosts");
    if (!j_profile["hosts"].is_array())
        Config::error("Profile hosts must be an array of strings");

    if (j_profile.find("keyfile") != j_profile.end())
        if (!j_profile["keyfile"].is_string())
            Config::error("Profile keyfile must be of type string");
}


/*************************************************
 * Config Private Methods
 ************************************************/


json Config::get_config() {
    char *home = getenv("HOME");
    if (home == NULL)
        die("Environment variable $HOME is not set");

    if (!file_exists(this->config_fn))
        die("Config file does not exist:", config_fn);

    ifstream fs(this->config_fn);

    json config;
    fs >> config;
    return config;
}


void Config::parse_config(json config) {
    string k_ssh_opts = "ssh_options";
    if (config.find(k_ssh_opts) != config.end())
        this->ssh_opts = parse_array<string>(k_ssh_opts, config[k_ssh_opts]);

    string k_profiles = "profiles";
    if (config.find(k_profiles) == config.end())
        this->error("Config must specify an array of profiles");
    this->profiles = parse_array<Profile>(k_profiles, config[k_profiles]);
}


/*************************************************
 * Config Public Methods
 ************************************************/


template<typename... T>
void Config::error(T... ts) {
    cerr << "Error in config file:" << endl;
    die(ts...);
}


Config::Config(string& fn) {
    this->config_fn = fn;
    this->ssh_opts = {"-oConnectTimeout=5"};
    this->parse_config(this->get_config());
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

    if (!home.size())
        home = string(getpwuid(getuid())->pw_dir);

    if (!home.size())
        die("Home directory of user could not be determined");

    return home;
}


vector<string> select_host(Config& config) {
    vector<string> profile_names = config.get_profile_names();
    int profile_i = Listbox(profile_names).run();
    cout << endl;
    if (profile_i < 0)
        die();

    vector<string> chosen_opts;

    Profile& profile = config.profiles[profile_i];

    if (profile.keyfile.size()) {
        chosen_opts.push_back("-i");
        chosen_opts.push_back(profile.keyfile);
    }

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
    chosen_opts.push_back(addr);

    return chosen_opts;
}


void attempt_ssh(char *args[]) {
    int stat, pid = fork();
    if (pid < 0) {
        die("Could not fork()");
    } else if (pid == 0) {
        // Child
        execv("/usr/bin/ssh", args);
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

    vector<string> chosen_opts = select_host(config);

    // Combine all arguments into one vector
    vector<string> all_opts = config.ssh_opts;
    all_opts.insert(all_opts.end(), chosen_opts.begin(), chosen_opts.end());
    // Get the arguments as a char*[]
    int args_len = 1 + all_opts.size() + 1;
    char *args[args_len] = { (char*)"ssh" };
    for (unsigned i=0; i<all_opts.size(); i++)
        args[i+1] = const_cast<char*>(all_opts[i].c_str());
    // Array has to be NULL-terminated for exec()
    args[args_len-1] = NULL;

    attempt_ssh(args);

    return 0;
}
