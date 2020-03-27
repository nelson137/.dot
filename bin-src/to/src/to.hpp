#ifndef TO_HPP
#define TO_HPP


#include <algorithm>
#include <iostream>
#include <string>
#include <queue>
#include <vector>

#include "consts.hpp"
#include "exec.hpp"
#include "util.hpp"

using namespace std;


extern string LANG_NAMES[];

enum Lang {
    NO_LANG, LANG_ASM, LANG_C, LANG_CPP
};


class To {

    private:
        void auto_bin_name();
        void set_lang(string);
        void auto_lang();

        void compile_asm();
        void compile_c();
        void compile_cpp();

    public:
        int commands;
        string src_name;
        string obj_name;
        string bin_name;
        vector<string> exec_args;
        Lang lang;

        void parse_args(int, char *[]);

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
