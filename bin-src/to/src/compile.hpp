#ifndef COMPILE_HPP
#define COMPILE_HPP


#include <string>
#include <vector>

#include "exec.hpp"
#include "prog.hpp"
#include "util.hpp"

using namespace std;


void compile_asm(Prog const& prog);


void compile_c(Prog const& prog);


void compile_cpp(Prog const& prog);


#endif
