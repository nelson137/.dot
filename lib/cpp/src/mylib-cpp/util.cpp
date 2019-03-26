#include <string>
#include <vector>

#include "mylib.hpp"

using namespace std;


/**
 * Set `handler` as the handler function for signal `sig`.
 */
void catchSig(int sig, void (*handler)(int)) {
    struct sigaction sa;
    sa.sa_handler = handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(sig, &sa, NULL);
}


/**
 * Return whether a file exists.
 */
bool file_exists(string fn) {
    struct stat s;
    return stat(fn.c_str(), &s) == 0;
}


/**
 * Return the given string with all leading and trailing whitespace removed.
 */
string trim_whitespace(string str) {
    static string whitespace = " \t\n\v\f\r";
    // Index of first non-whitespace char
    size_t begin = str.find_first_not_of(whitespace);
    // Index of last non-whitespace char
    size_t end = str.find_last_not_of(whitespace);
    return str.substr(begin, end-begin+1);
}


/**
 * Return a vector of words in str, using delim as the delimeter.
 * The default delim is a space.
 * Example:
 *     vector<string> v = split("a b c");  // {"a", "b", "c"}
 */
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


void die(int code) {
    exit(code);
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
