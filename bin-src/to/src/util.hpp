#ifndef UTIL_HPP
#define UTIL_HPP


#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>

#include <sys/stat.h>

using namespace std;


template<typename L, typename R>
void append(L& l, R const& r) {
    l.insert(l.end(), r.begin(), r.end());
}


/**
 * Ask the user to remove the given file.
 */
void ask_rm_file(string file);


void die(int code = 1);


template<typename... Ts>
void die(int code, string t, Ts... ts) {
    vector<string> tokens = {t, ts...};
    if (tokens.size()) {
        cerr << tokens[0] << endl;
        for (unsigned i=0; i<tokens.size(); i++)
            cerr << tokens[i];
    }
    die(code);
}


template<typename... Ts>
void die(string t, Ts... ts) {
    die(1, t, ts...);
}


/**
 * Return whether a file is executable.
 */
bool file_executable(string fn);


/**
 * Return whether a file exists.
 */
bool file_exists(string fn);


bool read_fd(int fd, string& dest);


/**
 * Remove the file with the given name.
 * Exit the program if it fails.
 */
void rm(string fn);


/**
 * Return a vector of words in str, using delim as the delimeter.
 * The default delim is a space.
 * Example:
 *     vector<string> v = split("a b c");  // {"a", "b", "c"}
 */
vector<string> split(string str, string delim = " ");


#endif
