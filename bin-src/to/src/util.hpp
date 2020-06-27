#ifndef UTIL_HPP
#define UTIL_HPP


#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>

#include <sys/stat.h>

#include "consts.hpp"

using namespace std;


template<typename L, typename R>
void append(L& l, R const& r) {
    l.insert(l.end(), r.begin(), r.end());
}


/**
 * Ask the user to remove the given file.
 */
void ask_rm_file(string file);


void die();


template<typename... Strings>
void die(int code, Strings... msg) {
    vector<string> tokens = { msg... };
    if (tokens.size()) {
        auto it = tokens.cbegin();
        cerr << *it++;
        for (; it!=tokens.cend(); it++)
            cerr << ' ' << *it;
    }
    cerr << endl;
    exit(code);
}


template<typename... Strings>
void die(const string& m, Strings... msg) {
    die(1, m, msg...);
}


/**
 * Return whether a file is executable.
 */
bool file_executable(string fn);


/**
 * Return whether a file exists.
 */
bool file_exists(string fn);


/**
 * Remove the file with the given name.
 * Exit the program if it fails.
 */
void rm(string fn);


/**
 * Return the value for the environment variable named key.
 * If no variable is defined return an empty string.
 */
string safe_getenv(const string& key);


/**
 * Return a vector of words in str, using delim as the delimeter.
 * The default delim is a space.
 * Example:
 *     vector<string> v = split("a b c");  // {"a", "b", "c"}
 */
vector<string> split(string str, string delim = " ");


#endif
