#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include "mylib++.hpp"

#define CMD_COMPILE   1  // 0000 0001
#define CMD_EXECUTE   2  // 0000 0010
#define CMD_REMOVE    4  // 0000 0100
#define CMD_LOUD      8  // 0000 1000
#define CMD_DRYRUN   16  // 0001 0000

#define NASM       "/usr/bin/nasm"
#define LD         "/usr/bin/ld"
#define GCC        "/usr/bin/gcc"
#define PKGCONFIG  "/usr/bin/pkg-config"
#define GPP        "/usr/bin/g++"

using namespace std;


enum Argtype {
    HYPHEN,
    SHORT_OPT,
    COMPOUND_SHORT_OPT,
    POSITIONAL_FLAG,
    LONG_OPT,
    POSITIONAL,
};

enum Lang {
    NO_LANG, LANG_ASM, LANG_C, LANG_CPP
};


char *USAGE = (char*)
    "Usage: to [-h] [-l LANG] [-o OUTFILE] <commands> <infile> [ARGS...]\n";


void usage() {
    cerr << USAGE;
    cerr << "See `to --help` for more information" << endl;
    die();
}


void help() {
    cout << USAGE;
    puts("");
    puts("Note");
    puts("  All arguments after <infile> will be passed to the program if");
    puts("  the e command is given.");
    puts("");
    puts("Commands");
    puts("  c          Compile the program");
    puts("  e          Execute the compiled program");
    puts("  r          Remove the binary and all compilation files");
    puts("  l          Print the OUTPUT and END OUTPUT messages");
    puts("  d          Print out the commands that would be executed in");
    puts("             response to the c, e, and r commands");
    puts("");
    puts("Positional Arguments");
    puts("  commands   A single word consisting of any commands in any order");
    puts("  infile     The source file for a single-file C, C++, or Linux");
    puts("             x86 Assembly program");
    puts("");
    puts("Options");
    puts("  -h, --help");
    puts("             Print this help message and exit");
    puts("  -o, --outfile OUTFILE");
    puts("             What name to give the binary");
    puts("  -l, --language LANG");
    puts("             The language for which the program should be compiled");
    exit(0);
}


/**
 * Die and print an error message if the given executable does not exist.
 */
void check_executable_exists(string exe) {
    if (!file_exists(exe))
        die("Executable does not exist:", exe);
}


/**
 * Remove the file with the given name.
 * Exit the program if it fails.
 */
void rm(string fn) {
    if (remove(fn.c_str()))
        die("Could not remove file:", fn);
}


/**
 * Ask the user to remove the given file.
 */
void ask_rm_file(string file) {
    cout << "Would you like to remove it [y/n]? ";
    string response;
    cin >> response;
    tolower(response[0]) == 'y' ? rm(file) : die();
}


/*************************************************
 * Prog
 ************************************************/


class Prog {
    private:
        bool parsing_opts = true;

        Argtype arg_type(string);
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
        bool wrap_output;

        void parse_args(int, char *[]);
};


/*************************************************
 * Prog Private Methods
 ************************************************/


Argtype Prog::arg_type(string arg) {
    int arglen = arg.length();

    if (this->parsing_opts && arglen > 0 && arg[0] == '-') {
        if (arglen == 1)
            return HYPHEN;
        else if (arglen == 2)
            return arg[1] == '-' ? POSITIONAL_FLAG : SHORT_OPT;
        else
            return arg[1] == '-' ? LONG_OPT : COMPOUND_SHORT_OPT;
    } else {
        return POSITIONAL;
    }
}


void Prog::auto_bin_name() {
    this->bin_name = this->src_name[0] == '/' ? "" : "./";
    this->bin_name += this->src_name + ".to";
}


void Prog::set_lang(string lang) {
    transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
    if (lang == "s" || lang == "asm" || lang == "assembly")
        this->lang = LANG_ASM;
    else if (lang == "c")
        this->lang = LANG_C;
    else if (lang == "cpp" || lang == "c++")
        this->lang = LANG_CPP;
    else
        die("Language not recognized:", lang);
}


void Prog::auto_lang() {
    size_t pos = this->src_name.rfind(".");
    string lang;
    if (pos != string::npos)
        lang = this->src_name.substr(pos+1);
    this->set_lang(lang);
}


/*************************************************
 * Prog Public Methods
 ************************************************/


void Prog::parse_args(int argc, char *argv[]) {
    if (argc < 3)
        usage();

    this->commands = 0;
    this->lang = NO_LANG;
    bool show_help = false;

    vector<string> args(argv+1, argv+argc);
    vector<string> pos_args;

    Argtype a_type;
    for (unsigned i=0; i<args.size(); i++) {
        a_type = this->arg_type(args[i]);

        switch(a_type) {

            case COMPOUND_SHORT_OPT:
                for (int j=args[i].length()-1; j>=1; j--)
                    args.insert(args.begin()+i+1, "-"+string(1, args[i][j]));
                break;

            case POSITIONAL_FLAG:
                this->parsing_opts = false;
                break;

            case HYPHEN:
            case SHORT_OPT:
            case LONG_OPT:
                if (args[i] == "-h" || args[i] == "--help")
                    show_help = true;
                else if (args[i] == "-l" || args[i] == "--language")
                    this->set_lang(args[++i]);
                else if (args[i] == "-o" || args[i] == "--outfile")
                    this->bin_name = args[++i];
                else
                    usage();
                break;

            case POSITIONAL:
                pos_args.push_back(args[i]);
                if (pos_args.size() >= 2)
                    parsing_opts = false;
                break;

        }
    }

    if (show_help)
        help();

    // Make sure there are at least commands and an src_name
    if (pos_args.size() < 2)
        usage();

    // Parse commands
    for (char c : pos_args[0]) {
        switch (c) {
            case 'c': this->commands |= CMD_COMPILE; break;
            case 'e': this->commands |= CMD_EXECUTE; break;
            case 'r': this->commands |= CMD_REMOVE;  break;
            case 'l': this->commands |= CMD_LOUD;    break;
            case 'd': this->commands |= CMD_DRYRUN;  break;
            default:  die("Command not recognized:", c);  break;
        }
    }

    // Error check commands
    if (this->commands == 0)
        die("No commands were given");

    this->src_name = pos_args[1];
    // Make sure src_name isn't an empty string
    if (this->src_name.empty())
        die("Infile cannot be an empty string");
    // Make sure src_name exists
    if (! file_exists(this->src_name))
        die("Infile does not exist:", this->src_name);

    // Get object file name
    this->obj_name = this->src_name + ".o";

    // Determine the binary filename if it wasn't specified by the user
    if (this->bin_name.empty())
        this->auto_bin_name();

    this->exec_args = vector<string>(pos_args.begin()+2, pos_args.end());

    if (this->lang == NO_LANG)
        this->auto_lang();

    this->wrap_output =
        this->commands & CMD_LOUD && !(this->commands & CMD_DRYRUN);
}


/*************************************************
 * Core Functions
 ************************************************/


void print_args(vector<string> args) {
    cout << args[0];
    for (unsigned i=1; i<args.size(); i++)
        cout << " " << args[i];
    cout << endl;
}


vector<string> get_lib_flags(string lib) {
    vector<string> pkg_conf_args = {PKGCONFIG, "--cflags", "--libs", lib};
    return split(trim_whitespace(easy_execute(pkg_conf_args, true).out));
}


template<typename... T>
vector<string> get_lib_flags(string a, T... ts) {
    vector<string> libraries = {a, ts...};

    vector<string> flags;
    for (auto& lib : libraries) {
        vector<string> lib_flags = get_lib_flags(lib);
        flags.insert(flags.end(), lib_flags.begin(), lib_flags.end());
    }

    return flags;
}


/*************************************************
 * Compile
 ************************************************/


void compile_asm(Prog& prog) {
    vector<string> nasm_args = {
        NASM, "-f", "elf64", prog.src_name, "-o", prog.obj_name};
    vector<string> ld_args = {LD, prog.obj_name, "-o", prog.bin_name};

    if (prog.commands & CMD_DRYRUN) {
        print_args(nasm_args);
        print_args(ld_args);
    } else {
        check_executable_exists(nasm_args[0]);
        check_executable_exists(ld_args[0]);

        int code;

        if ((code = easy_execute(nasm_args).exitstatus))
            die(code, "Could not create object file:", prog.obj_name);

        if ((code = easy_execute(ld_args).exitstatus))
            die(code, "Could not link object file:", prog.obj_name);
    }
}


void compile_c(Prog& prog) {
    vector<string> gcc_args = {
        GCC, "-x", "c", "-std=c11", "-O3", "-Wall", "-Werror",
        prog.src_name, "-o", prog.bin_name};

    char *c_include = getenv("C_SEARCH_LIBS");
    if (c_include != NULL) {
        vector<string> dirs = split(string(c_include));
        gcc_args.insert(gcc_args.end(), dirs.begin(), dirs.end());
    }

    vector<string> lib_flags = get_lib_flags("python3", "json-c");
    gcc_args.insert(gcc_args.end(), lib_flags.begin(), lib_flags.end());

    if (prog.commands & CMD_DRYRUN) {
        print_args(gcc_args);
    } else {
        check_executable_exists(gcc_args[0]);

        int code;
        if ((code = easy_execute(gcc_args).exitstatus))
            die(code, "Could not compile infile:", prog.src_name);
    }
}


void compile_cpp(Prog& prog) {
    vector<string> gpp_args = {
        GPP, "-x", "c++", "-std=c++11", "-O3", "-Wall", "-Werror",
        prog.src_name, "-o", prog.bin_name};

    char *c_include = getenv("CPLUS_SEARCH_LIBS");
    if (c_include != NULL) {
        vector<string> dirs = split(string(c_include));
        gpp_args.insert(gpp_args.end(), dirs.begin(), dirs.end());
    }

    if (prog.commands & CMD_DRYRUN) {
        print_args(gpp_args);
    } else {
        check_executable_exists(gpp_args[0]);

        int code;
        if ((code = easy_execute(gpp_args).exitstatus))
            die("Could not compile infile:", prog.src_name);
    }
}


void to_compile(Prog& prog) {
    // Ask to remove the object file if it already exists
    if (prog.lang == LANG_ASM && file_exists(prog.obj_name)) {
        cout << "Object file exists: " << prog.obj_name << endl;
        ask_rm_file(prog.obj_name);
    }

    // Ask to remove the outfile if it already exists
    if (file_exists(prog.bin_name)) {
        cout << "Outfile exists: " << prog.bin_name << endl;
        ask_rm_file(prog.bin_name);
    }

    switch(prog.lang) {
        case LANG_ASM: compile_asm(prog); break;
        case LANG_C:   compile_c  (prog); break;
        case LANG_CPP: compile_cpp(prog); break;
        default: die("Compilation not implemented for", prog.lang);
    }
}


/*************************************************
 * Execute
 ************************************************/


int to_execute(Prog& prog) {
    if (prog.wrap_output)
        cout << "===== OUTPUT =====" << endl;
    int exitstatus = easy_execute(prog.exec_args).exitstatus;
    if (prog.wrap_output)
        cout << "===== END OUTPUT =====" << endl;
    return exitstatus;
}


/*************************************************
 * Remove
 ************************************************/


void to_remove(Prog& prog) {
    rm(prog.bin_name);
    if (prog.lang == LANG_ASM)
        rm(prog.obj_name);
}


/*************************************************
 * Main
 ************************************************/


int main(int argc, char *argv[]) {
    Prog parser;
    parser.parse_args(argc, argv);

    int exitstatus = 0;

    // Compile the program
    to_compile(parser);

    // Execute the program
    if (parser.commands & CMD_EXECUTE)
        exitstatus = to_execute(parser);

    // Remove the generated files
    if (parser.commands & CMD_REMOVE)
        to_remove(parser);

    return exitstatus;
}
