#ifndef EXEC_HPP
#define EXEC_HPP


#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>
#include <wait.h>

#include <sys/stat.h>

#include "util.hpp"

using namespace std;


struct exec_ret {
    int exitstatus;
    string out;
    string err;

    operator int();
};


class ExecArgs {

private:
    vector<char*> args;

    char *string_copy(string& str);

public:
    char *bin;

    template<template<typename,typename> class T>
    void init(string bin, T<string,allocator<string>> args) {
        this->bin = this->string_copy(bin);
        this->args = {this->bin, nullptr};

        this->args.reserve(this->args.size() + args.size());
        for (auto it=args.begin(); it!=args.end(); it++)
            this->push_back(*it);
    }

    template<template<typename,typename> class T>
    ExecArgs(string bin, T<string,allocator<string>> args) {
        init(bin, args);
    }

    template<
        typename... Str,
        typename = enable_if_t<(... && std::is_convertible<Str, string>::value)>
    >
    ExecArgs(string bin, const Str... strs) {
        init(bin, vector<string>{strs...});
    }

    template<template<typename,typename> class T>
    ExecArgs(T<string,allocator<string>> args) {
        string bin;
        if (args.size()) {
            bin = args[0];
            args.erase(args.begin());
        }
        init(bin, args);
    }

    ~ExecArgs();

    void push_back(string str);

    char **get();

};


template<typename T>
int execute(exec_ret& er, const T& args, bool capture_output=false) {
    ExecArgs ea(args);

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

        execv(ea.bin, ea.get());
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


template<typename T>
exec_ret easy_execute(const T& args, bool capture_output=false) {
    exec_ret er;
    execute(er, args, capture_output);
    return er;
}


#endif
