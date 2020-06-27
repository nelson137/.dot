#ifndef STEPS_HPP
#define STEPS_HPP


#include <initializer_list>
#include <iostream>
#include <list>
#include <string>

#include "consts.hpp"
#include "exec.hpp"
#include "util.hpp"

#define C_ARGS "-O3", "-pedantic", "-Wall", "-Werror"

using namespace std;


class BuildStep {

private:
    string outfile;
    list<string> args;

public:
    BuildStep(const string& of);
    BuildStep(const string& of, const list<string>& l);
    BuildStep(const string& of, const initializer_list<string>& il);

    void add_arg(const string& arg);

    template<typename Container>
    void add_args(const Container& args) {
        for (const string& a : args)
            this->args.push_back(a);
    }

    string perform_step(const string& infile, bool force);

};


#endif
