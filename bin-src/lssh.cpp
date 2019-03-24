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


/*************************************************
 * Classes
 ************************************************/


struct Profile {

    string name;
    string user;
    vector<string> hosts;
    string keyfile;

    Profile(json::iterator::reference&);

};


class Config {

private:
    string config_fn;

    string get_home_dir();
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


template<typename T, typename U>
vector<U> parse_array(json& j, string key, string type,
                      function<U(T)> predicate) {
    json j_arr = j[key];
    if (!j_arr.is_array())
        Config::error("Value for key '"+key+"' must be of type 'array'");
    vector<U> arr;
    for (auto&& it=j_arr.begin(); it!=j_arr.end(); it++) {
        if (it.value().type_name() == type)
            arr.push_back(predicate(it.value()));
        else
            Config::error("Elements of array '"+key+"' must be of type '"
                          +type+"'");
    }
    return arr;
}


template<typename T>
vector<T> parse_obj_array(json& j, string key, function<T(json)> predicate) {
    return parse_array<json>(j, key, "object", predicate);
}


template<typename T>
vector<T> parse_array(json& j, string key, string type) {
    return parse_array<T,T>(j, key, type, [](T t)->T{ return t; });
}


vector<string> parse_str_array(json& j, string key) {
    return parse_array<string>(j, key, "string");
}


vector<json> parse_obj_array(json& j, string key) {
    return parse_array<json>(j, key, "object");
}


/*************************************************
 * Profile Methods
 ************************************************/


Profile::Profile(json::iterator::reference& j_profile) {
    if (j_profile.find("name") == j_profile.end())
        Config::error("Profiles must specify a name");
    if (!j_profile["name"].is_string())
        Config::error("Profile names must be of type string");
    this->name = j_profile["name"];

    if (j_profile.find("username") == j_profile.end())
        Config::error("Profiles must specify a username");
    if (!j_profile["username"].is_string())
        Config::error("Profile usernames must be of type string");
    this->user = j_profile["username"];

    if (j_profile.find("hosts") == j_profile.end())
        Config::error("Profiles must specify an array of hosts");
    json j_hosts = j_profile["hosts"];
    if (!j_hosts.is_array())
        Config::error("Profile hosts must be an array of strings");
    for (auto&& it=j_hosts.begin(); it!=j_hosts.end(); it++)
        this->hosts.push_back(it.value());

    if (j_profile.find("keyfile") != j_profile.end()) {
        json j_kf = j_profile["keyfile"];
        if (!j_kf.is_string())
            Config::error("Profile keyfile must be of type string");
        this->keyfile = j_kf.get<string>();
    }
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


void Config::parse_config(json config) {
    if (config.find("ssh_options") != config.end())
        this->ssh_opts = parse_str_array(config, "ssh_options");

    if (config.find("profiles") == config.end())
        this->error("Config must specify an array of profiles");
    this->profiles = parse_obj_array<Profile>(config, "profiles",
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
    if (home.size())
        return home;

    struct passwd *pd = getpwuid(getuid());
    if (pd != NULL)
        return string(pd->pw_dir);

    die("Home directory of user could not be determined");

    // Suppress control reaches end of non-void function error
    return "";
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

    cout << endl;
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
