#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
#include <ctype.h>
#include <unistd.h>
#include <wait.h>

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

struct PRet {
    int exitstatus;
    string out;
    string err;
};

struct Options {
    int commands;
    string src_name;
    string obj_name;
    string bin_name;
    vector<string> bin_args;
    Lang lang;
    bool wrap_output;
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


bool read_fd(int fd, string *dest) {
    int count;
    char buff[128];

    do {
        count = read(fd, buff, sizeof(buff)-1);
        if (count == -1)
            return false;
        buff[count] = '\0';
        *dest += buff;
    } while (count > 0);

    return true;
}


/*************************************************
 * Parser
 ************************************************/


class Parser {
    private:
        bool parsing_opts = true;

        Argtype arg_type(string);
        void auto_bin_name();
        void set_lang(string);
        void auto_lang();

    public:
        Options opts;
        Options parse_args(int, char *[]);
};


/*************************************************
 * Parser Private Methods
 ************************************************/


Argtype Parser::arg_type(string arg) {
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


void Parser::auto_bin_name() {
    this->opts.bin_name = this->opts.src_name[0] == '/' ? "" : "./";
    this->opts.bin_name += this->opts.src_name + ".to";
}


void Parser::set_lang(string lang) {
    transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
    if (lang == "s" || lang == "asm" || lang == "assembly")
        this->opts.lang = LANG_ASM;
    else if (lang == "c")
        this->opts.lang = LANG_C;
    else if (lang == "cpp" || lang == "c++")
        this->opts.lang = LANG_CPP;
    else
        die("Language not recognized:", lang);
}


void Parser::auto_lang() {
    size_t pos = this->opts.src_name.rfind(".");
    string lang;
    if (pos != string::npos)
        lang = this->opts.src_name.substr(pos+1);
    this->set_lang(lang);
}


/*************************************************
 * Parser Public Methods
 ************************************************/


Options Parser::parse_args(int argc, char *argv[]) {
    if (argc < 3)
        usage();

    this->opts.commands = 0;
    this->opts.lang = NO_LANG;
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
                    this->opts.bin_name = args[++i];
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
            case 'c': this->opts.commands |= CMD_COMPILE; break;
            case 'e': this->opts.commands |= CMD_EXECUTE; break;
            case 'r': this->opts.commands |= CMD_REMOVE;  break;
            case 'l': this->opts.commands |= CMD_LOUD;    break;
            case 'd': this->opts.commands |= CMD_DRYRUN;  break;
            default:  die("Command not recognized:", c);  break;
        }
    }

    // Error check commands
    if (this->opts.commands == 0)
        die("No commands were given");

    this->opts.src_name = pos_args[1];
    // Make sure src_name isn't an empty string
    if (this->opts.src_name.empty())
        die("Infile cannot be an empty string");
    // Make sure src_name exists
    if (! file_exists(this->opts.src_name))
        die("Infile does not exist:", this->opts.src_name);

    // Get object file name
    this->opts.obj_name = this->opts.src_name + ".o";

    // Determine the binary filename if it wasn't specified by the user
    if (this->opts.bin_name.empty())
        this->auto_bin_name();

    this->opts.bin_args = vector<string>(pos_args.begin()+2, pos_args.end());

    if (this->opts.lang == NO_LANG)
        this->auto_lang();

    this->opts.wrap_output =
        this->opts.commands & CMD_LOUD && !(this->opts.commands & CMD_DRYRUN);

    return this->opts;
}


/*************************************************
 * Core Functions
 ************************************************/


int execute(PRet *ret, vector<string> args, bool capture_output=false) {
    // Convert vector<string> to a char *[]
    char *argv[args.size()+1];
    unsigned i;
    for (i=0; i<args.size(); i++)
        argv[i] = (char*) args[i].c_str();
    // Arguments array has to be null-terminated
    argv[i] = NULL;

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

        execv(argv[0], argv);
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

        ret->exitstatus = WEXITSTATUS(status);

        if (capture_output) {
            // Read child's stdout
            if (! read_fd(parent_out_fd, &ret->out))
                die("Could not read stdout");
            // Read child's stderr
            if (! read_fd(parent_err_fd, &ret->err))
                die("Could not read stderr");
        }

        close(parent_out_fd);
        close(parent_err_fd);
    }

    return ret->exitstatus;
}


int easy_execute(vector<string> args, bool capture_output=false) {
    PRet ret;
    execute(&ret, args, capture_output);
    return ret.exitstatus;
}


void print_args(vector<string> args) {
    cout << args[0];
    for (unsigned i=1; i<args.size(); i++)
        cout << " " << args[i];
    cout << endl;
}


vector<string> get_lib_flags(string lib) {
    PRet ret;
    vector<string> pkg_conf_args = {PKGCONFIG, "--cflags", "--libs", lib};
    execute(&ret, pkg_conf_args, true);
    return split(trim_whitespace(ret.out));
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


void compile_asm(Options& opts) {
    vector<string> nasm_args = {
        NASM, "-f", "elf64", opts.src_name, "-o", opts.obj_name};
    vector<string> ld_args = {LD, opts.obj_name, "-o", opts.bin_name};

    if (opts.commands & CMD_DRYRUN) {
        print_args(nasm_args);
        print_args(ld_args);
    } else {
        check_executable_exists(nasm_args[0]);
        check_executable_exists(ld_args[0]);

        int code;

        if ((code = easy_execute(nasm_args)))
            die(code, "Could not create object file:", opts.obj_name);

        if ((code = easy_execute(ld_args)))
            die(code, "Could not link object file:", opts.obj_name);
    }
}


void compile_c(Options& opts) {
    vector<string> gcc_args = {
        GCC, "-x", "c", "-std=c11", "-O3", "-Wall", "-Werror",
        opts.src_name, "-o", opts.bin_name};

    char *c_include = getenv("C_SEARCH_LIBS");
    if (c_include != NULL) {
        vector<string> dirs = split(string(c_include));
        gcc_args.insert(gcc_args.end(), dirs.begin(), dirs.end());
    }

    vector<string> lib_flags = get_lib_flags("python3", "json-c");
    gcc_args.insert(gcc_args.end(), lib_flags.begin(), lib_flags.end());

    if (opts.commands & CMD_DRYRUN) {
        print_args(gcc_args);
    } else {
        check_executable_exists(gcc_args[0]);

        int code;
        if ((code = easy_execute(gcc_args)))
            die(code, "Could not compile infile:", opts.src_name);
    }
}


void compile_cpp(Options& opts) {
    vector<string> gpp_args = {
        GPP, "-x", "c++", "-std=c++11", "-O3", "-Wall", "-Werror",
        opts.src_name, "-o", opts.bin_name};

    char *c_include = getenv("CPLUS_SEARCH_LIBS");
    if (c_include != NULL) {
        vector<string> dirs = split(string(c_include));
        gpp_args.insert(gpp_args.end(), dirs.begin(), dirs.end());
    }

    if (opts.commands & CMD_DRYRUN) {
        print_args(gpp_args);
    } else {
        check_executable_exists(gpp_args[0]);

        int code;
        if ((code = easy_execute(gpp_args)))
            die("Could not compile infile:", opts.src_name);
    }
}


void to_compile(Options& opts) {
    // Ask to remove the object file if it already exists
    if (opts.lang == LANG_ASM && file_exists(opts.obj_name)) {
        cout << "Object file exists: " << opts.obj_name << endl;
        ask_rm_file(opts.obj_name);
    }

    // Ask to remove the outfile if it already exists
    if (file_exists(opts.bin_name)) {
        cout << "Outfile exists: " << opts.bin_name << endl;
        ask_rm_file(opts.bin_name);
    }

    switch(opts.lang) {
        case LANG_ASM: compile_asm(opts); break;
        case LANG_C:   compile_c  (opts); break;
        case LANG_CPP: compile_cpp(opts); break;
        default: die("Compilation not implemented for", opts.lang);
    }
}


/*************************************************
 * Execute
 ************************************************/


int to_execute(Options& opts) {
    if (opts.wrap_output)
        cout << "===== OUTPUT =====" << endl;
    int exitstatus = easy_execute(opts.bin_args);
    if (opts.wrap_output)
        cout << "===== END OUTPUT =====" << endl;
    return exitstatus;
}


/*************************************************
 * Remove
 ************************************************/


void to_remove(Options& opts) {
    rm(opts.bin_name);
    if (opts.lang == LANG_ASM)
        rm(opts.obj_name);
}


/*************************************************
 * Main
 ************************************************/


int main(int argc, char *argv[]) {
    Parser parser;
    Options opts = parser.parse_args(argc, argv);

    int exitstatus = 0;

    // Compile the program
    to_compile(opts);

    // Execute the program
    if (opts.commands & CMD_EXECUTE)
        exitstatus = to_execute(opts);

    // Remove the generated files
    if (opts.commands & CMD_REMOVE)
        to_remove(opts);

    return exitstatus;
}
