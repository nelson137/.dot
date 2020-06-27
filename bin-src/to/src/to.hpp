#ifndef TO_HPP
#define TO_HPP


#include <algorithm>
#include <iostream>
#include <string>
#include <queue>
#include <vector>

#include "consts.hpp"
#include "exec.hpp"
#include "steps.hpp"
#include "util.hpp"

using namespace std;


class To {

    private:
        void auto_bin_name();
        void set_lang(string lang);
        void auto_lang();

        void compile_asm();
        void compile_c();
        void compile_cpp();

    public:
        int commands;
        string src_name;
        string bin_name;
        vector<string> exec_args;
        list<BuildStep> build_steps;
        list<string> intermediate_files;

        static int run(int argc, char *argv[]);

        void parse(int argc, char *argv[]);

        bool should_compile();
        bool should_execute();
        bool should_remove();

        void compile();
        int execute();
        void remove();

};


void help();


void usage();


#endif
