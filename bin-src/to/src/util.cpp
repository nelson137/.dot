#include "util.hpp"


void ask_rm_file(string file) {
    cout << "Would you like to remove it [y/n]? ";
    string response;
    cin >> response;
    tolower(response[0]) == 'y' ? rm(file) : die();
}


void die(int code) {
    exit(code);
}


bool file_executable(string fn) {
    return !access(fn.c_str(), X_OK);
}


bool file_exists(string fn) {
    struct stat s;
    return stat(fn.c_str(), &s) == 0;
}


bool read_fd(int fd, string& dest) {
    int count;
    char buff[128];

    do {
        count = read(fd, buff, sizeof(buff)-1);
        if (count == -1)
            return false;
        buff[count] = '\0';
        dest += buff;
    } while (count > 0);

    return true;
}


void rm(string fn) {
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
