#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include <sys/stat.h>
#include <unistd.h>
#include <wait.h>

#include "mylib++.hpp"

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


int execute(exec_ret& er, vector<string>& args, bool capture_output) {
    // Get args as a vector<char*>
    vector<char*> argv(args.size() + 1);
    transform(args.begin(), args.end(), argv.begin(),
        [](string& s){ return const_cast<char*>(s.c_str()); });
    argv.push_back(NULL);

    int pipes[2][2];
    int *out_pipe = pipes[0];
    int *err_pipe = pipes[1];

    // Create the stdout and stderr pipes
    if (capture_output) {
        if (pipe(out_pipe) < 0)
            die("Could not create pipe for stdout");
        if (pipe(err_pipe) < 0)
            die("Could not create pipe for stderr");
    }

    int child_out_fd = out_pipe[1];
    int child_err_fd = err_pipe[1];
    int parent_out_fd = out_pipe[0];
    int parent_err_fd = err_pipe[0];

    int pid = fork();

    if (pid == -1) {
        die("Could not fork");

    } else if (pid == 0) {
        /**
         * Child
         */

        if (capture_output) {
            dup2(child_out_fd, STDOUT_FILENO);
            dup2(child_err_fd, STDERR_FILENO);
        }

        close(child_out_fd);
        close(child_err_fd);
        close(parent_out_fd);
        close(parent_err_fd);

        execv(argv[0], argv.data());
        _exit(0);
    } else {
        /**
         * Parent
         */

        // Child's end of the pipes are not needed
        close(child_out_fd);
        close(child_err_fd);

        // Wait for child to complete
        int status;
        waitpid(pid, &status, 0);

        er.exitstatus = WEXITSTATUS(status);

        if (capture_output) {
            // Read child's stdout
            if (! read_fd(parent_out_fd, er.out))
                die("Could not read stdout");
            // Read child's stderr
            if (! read_fd(parent_err_fd, er.err))
                die("Could not read stderr");
        }

        close(parent_out_fd);
        close(parent_err_fd);
    }

    return er.exitstatus;
}


exec_ret easy_execute(vector<string>& args, bool capture_output) {
    exec_ret er;
    execute(er, args, capture_output);
    return er;
}
