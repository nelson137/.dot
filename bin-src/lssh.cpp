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


char **args_for_exec(vector<string>& strings) {
    char **args = (char**) malloc(sizeof(char*) * (strings.size()+1));
    unsigned i, len;
    for (i=0; i<strings.size(); i++) {
        len = strings[i].length();
        args[i] = (char*) malloc(sizeof(char) * (len+1));
        strcpy(args[i], strings[i].c_str());
        args[i][len] = '\0';
    }
    args[i] = NULL;
    return args;
}


char **free_args_for_exec(char **args) {
    for (int i=0; args[i]; i++)
        free(args[i]);
    free(args);
    return NULL;
}


/*************************************************
 * Classes
 ************************************************/


struct Profile {

    string name;
    string user;
    vector<string> hosts;

    void validate_data(json::iterator::reference&);

    Profile(json::iterator::reference&);

};


class Config {

private:
    string config_fn;

    string get_home_dir();
    json get_config();

    template<typename T, typename U>
        vector<U> parse_array(json&, string, string, function<U(T)>);
    template<typename T>
        vector<T> parse_obj_array(json&, string, function<T(json)>);

    template<typename T>
        vector<T> parse_array(json&, string, string);
    vector<string> parse_str_array(json&, string);
    vector<json> parse_obj_array(json&, string);

    void parse_config(json);

public:
    vector<Profile> profiles;
    vector<string> ssh_options;

    template<typename... T>
        static void error(T...);

    Config(string&);

    vector<string> get_profile_names();

};


/*************************************************
 * Profile Methods
 ************************************************/


void Profile::validate_data(json::iterator::reference& j_profile) {
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
}


Profile::Profile(json::iterator::reference& j_profile) {
    this->validate_data(j_profile);
    this->name = j_profile["name"];
    this->user = j_profile["username"];
    json hosts = j_profile["hosts"];
    for (auto&& it=hosts.begin(); it!=hosts.end(); it++)
        this->hosts.push_back(it.value());
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

    ifstream fs;
    fs.open(this->config_fn);

    json config;
    fs >> config;
    return config;
}


template<typename T, typename U>
vector<U> Config::parse_array(json& j, string key, string type,
                              function<U(T)> predicate) {
    json j_arr = j[key];
    if (!j_arr.is_array())
        this->error("Value for key '"+key+"' must be of type 'array'");
    vector<U> arr;
    for (auto&& it=j_arr.begin(); it!=j_arr.end(); it++) {
        if (it.value().type_name() == type)
            arr.push_back(predicate(it.value()));
        else
            this->error("Elements of array '"+key+"' must be of type '"
                        +type+"'");
    }
    return arr;
}


template<typename T>
vector<T> Config::parse_obj_array(json& j, string key,
                                  function<T(json)> predicate) {
    return this->parse_array<json>(j, key, "object", predicate);
}


template<typename T>
vector<T> Config::parse_array(json& j, string key, string type) {
    return this->parse_array<T,T>(j, key, type, [](T t)->T{ return t; });
}


vector<string> Config::parse_str_array(json& j, string key) {
    return this->parse_array<string>(j, key, "string");
}


vector<json> Config::parse_obj_array(json& j, string key) {
    return this->parse_array<json>(j, key, "object");
}


void Config::parse_config(json config) {
    if (!config["ssh_options"].is_null())
        this->ssh_options = this->parse_str_array(config, "ssh_options");

    if (config["profiles"].is_null())
        this->error("Config must specify an array of profiles");
    this->profiles = this->parse_obj_array<Profile>(config, "profiles",
        [](json j)->Profile{ return Profile(j); });
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
    this->ssh_options = {"-oConnectTimeout=5"};
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


void attempt_ssh(string const& addr, vector<string> str_opts) {
    str_opts.insert(str_opts.begin(), "ssh");
    str_opts.push_back(addr);
    char **opts = args_for_exec(str_opts);

    int stat, pid = fork();
    if (pid < 0) {
        die("Could not fork()");
    } else if (pid == 0) {
        // Child
        execv("/usr/bin/ssh", opts);
        _exit(127);
    } else {
        // Parent
        wait(&stat);
    }

    opts = free_args_for_exec(opts);
}


/*************************************************
 * Main
 ************************************************/


int main() {
    string config_fn = get_home_dir() + "/.lsshrc";
    Config config(config_fn);

    string addr = select_profile(config);
    attempt_ssh(addr, config.ssh_options);

    return 0;
}
