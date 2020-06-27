#include "util.hpp"


void ask_rm_file(string file) {
    cout << "Would you like to remove it [y/n]? ";
    string response;
    cin >> response;
    tolower(response[0]) == 'y' ? rm(file) : die();
}


void die() {
    exit(1);
}


bool file_executable(string fn) {
    return !access(fn.c_str(), X_OK);
}


bool file_exists(string fn) {
    struct stat s;
    return stat(fn.c_str(), &s) == 0;
}


void rm(string fn) {
    if (file_exists(fn))
        if (remove(fn.c_str()))
            die("Could not remove file:", fn);
}


string safe_getenv(const string& key) {
    char *v = getenv(key.c_str());
    return v == nullptr ? "" : v;
}


vector<string> split(string str, string delim) {
    vector<string> tokens;
    size_t prev = 0, curr = 0;

    do {
        curr = str.find(delim, prev);
        tokens.push_back(str.substr(prev, curr-prev));
        prev = curr + 1;
    } while (curr != string::npos);

    return tokens;
}
