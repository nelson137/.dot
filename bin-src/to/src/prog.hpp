#ifndef PROG_HPP
#define PROG_HPP


#include <algorithm>
#include <iostream>
#include <string>
#include <queue>
#include <vector>

#include "consts.hpp"
#include "util.hpp"

using namespace std;


extern string LANG_NAMES[];

enum Lang {
    NO_LANG, LANG_ASM, LANG_C, LANG_CPP
};


class Prog {
    private:
        bool parsing_opts = true;

        void auto_bin_name();
        void set_lang(string);
        void auto_lang();

    public:
        int commands;
        string src_name;
        string obj_name;
        string bin_name;
        vector<string> exec_args;
        Lang lang;

        void parse_args(int, char *[]);
};


void help();


void usage();


#endif
