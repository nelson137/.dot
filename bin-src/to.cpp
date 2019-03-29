#include <algorithm>
#include <iostream>
#include <queue>
#include <string>
#include <vector>

#include "mylib.hpp"

#define  ASSEMBLE   1  // 00000001
#define  COMPILE    2  // 00000010
#define  EXECUTE    4  // 00000100
#define  FORCE      8  // 00001000
#define  LANG      16  // 00010000
#define  OUTFILE   32  // 00100000
#define  REMOVE    64  // 01000000

#define  HAS_ASSEMBLE(x)  (x & ASSEMBLE)
#define  HAS_COMPILE(x)   (x & COMPILE)
#define  HAS_EXECUTE(x)   (x & EXECUTE)
#define  HAS_FORCE(x)     (x & FORCE)
#define  HAS_LANG(x)      (x & LANG)
#define  HAS_OUTFILE(x)   (x & OUTFILE)
#define  HAS_REMOVE(x)    (x & REMOVE)

#define  NASM       "/usr/bin/nasm"
#define  LD         "/usr/bin/ld"
#define  GCC        "/usr/bin/gcc"
#define  PKGCONFIG  "/usr/bin/pkg-config"
#define  GPP        "/usr/bin/g++"

using namespace std;


enum Lang {
    NO_LANG, LANG_ASM, LANG_C, LANG_CPP
};


string USAGE = "Usage: to [-h] <commands> <infile> [outfile] [lang] [ARGS...]";


void usage() {
    cerr << USAGE << endl;
    cerr << "See `to --help` for more information" << endl;
    die();
}


void help() {
    cout << USAGE << endl;
    puts("");
    puts("Note");
    puts("  All arguments after the last positional argument (outfile if the");
    puts("  outfile command (o) was given, lang if the lang command (x) was");
    puts("  given, otherwise infile) will be passed to the program if the");
    puts("  execute command (e) was given.");
    puts("");
    puts("Options");
    puts("  -h, --help   Print this help message and exit");
    puts("");
    puts("Positional Arguments");
    puts("  commands     A single word consisting of command characters in");
    puts("               any order");
    puts("  infile       The source file for a single-file C, C++, or Linux");
    puts("               x86 Assembly program");
    puts("  lang         The language to compile for");
    puts("  outfile      The name of the outfile");
    puts("");
    puts("Commands");
    puts("  a            Assemble the program (gcc -c)");
    puts("  c            Compile the program");
    puts("  d            Print out the commands that would be executed,");
    puts("               output is suitable for use in a shell");
    puts("  e            Execute the compiled program");
    puts("  f            Do not prompt before overwriting files");
    puts("  o            What to name the binary");
    puts("  r            Remove the binary and all compilation files");
    puts("  x            The language of the infile");
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


vector<string> include_args() {
    vector<string> include_paths = split(getenv("CPLUS_INCLUDE_PATH"), ":");
    for (unsigned i=0; i<include_paths.size(); i++)
        include_paths[i] = "-I" + include_paths[i];
    return include_paths;
}


vector<string> library_args() {
    vector<string> library_paths = split(getenv("LIBRARY_PATH"), ":");
    for (unsigned i=0; i<library_paths.size(); i++)
        library_paths[i] = "-L" + library_paths[i];
    return library_paths;
}


bool can_find_lib(string name) {
    vector<string> args = {"/usr/bin/ld", "-o", "/dev/null", name};
    append(args, include_args());
    append(args, library_args());
    return easy_execute(args, true).exitstatus == 0;
}


vector<string> can_find_libs(vector<string> libs) {
    vector<string> found_libs;
    copy_if(libs.begin(), libs.end(), back_inserter(found_libs),
        [](string& a){ return can_find_lib(a); });
    return found_libs;
}


bool is_clean(char& c) {
    return (43 <= c && c <= 57)
        || c == 61
        || (64 <= c && c <= 90)
        || c == 95
        || (97 <= c && c <= 122);
}


bool is_clean(string& str) {
    for (char c : str)
        if (!is_clean(c))
            return false;
    return true;
}


string sanitize(string str) {
    if (is_clean(str))
        return str;

    char singleQuote = '\'';
    size_t pos = 0;

    do {
        if ((pos = str.find(singleQuote, pos)) == string::npos)
            break;
        str.insert(pos, "'\\'");
        pos += 4;
    } while (true);
    return '\'' + str + '\'';
}


void print_args(vector<string> args) {
    cout << sanitize(args[0]);
    for (unsigned i=1; i<args.size(); i++)
        cout << " " << sanitize(args[i]);
    cout << endl;
}


/*************************************************
 * Prog
 ************************************************/


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


/*************************************************
 * Prog Private Methods
 ************************************************/


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
    this->commands = 0;
    this->lang = NO_LANG;
    bool show_help = false;

    queue<string> pos_args;

    string arg;
    for (int i=1; i<argc; i++) {
        arg = string(argv[i]);

        if (arg == "-h" || arg == "--help")
            show_help = true;
        else if (arg == "--")
            ;  // Do nothing
        else
            pos_args.push(arg);
    }

    if (argc < 3 || show_help)
        help();

    // Make sure there are at least commands and an src_name
    if (pos_args.size() < 2)
        usage();

    // Parse commands
    for (char c : pos_args.front()) {
        switch (c) {
            case 'a': this->commands |= ASSEMBLE; break;
            case 'c': this->commands |= COMPILE;  break;
            case 'e': this->commands |= EXECUTE;  break;
            case 'f': this->commands |= FORCE;    break;
            case 'x': this->commands |= LANG;     break;
            case 'o': this->commands |= OUTFILE;  break;
            case 'r': this->commands |= REMOVE;   break;
            default:  die("Command not recognized:", c);  break;
        }
    }
    pos_args.pop();

    // Error check commands
    if (this->commands == 0)
        die("No commands were given");

    this->src_name = pos_args.front();
    pos_args.pop();
    // Make sure src_name isn't an empty string
    if (this->src_name.empty())
        die("Infile cannot be an empty string");
    // Make sure src_name exists
    if (! file_exists(this->src_name))
        die("Infile does not exist:", this->src_name);

    if (HAS_OUTFILE(this->commands)) {
        if (!pos_args.size())
            usage();  // print error message?
        this->bin_name = pos_args.front();
        pos_args.pop();
    }

    if (HAS_LANG(this->commands)) {
        if (!pos_args.size())
            usage();  // print error message?
        this->set_lang(pos_args.front());
        pos_args.pop();
    } else {
        this->auto_lang();
    }

    if (HAS_EXECUTE(this->commands) && HAS_ASSEMBLE(this->commands)
            && !HAS_COMPILE(this->commands))
        die("Execution requires compilation (the 'c' command)");

    // Get object file name
    this->obj_name = this->src_name + ".o";

    // Determine the binary filename if it wasn't specified by the user
    if (this->bin_name.empty())
        this->auto_bin_name();

    this->exec_args.reserve(1 + pos_args.size());
    this->exec_args.push_back(this->bin_name);
    while (!pos_args.empty()) {
        this->exec_args.push_back(pos_args.front());
        pos_args.pop();
    }
}


/*************************************************
 * Core Functions
 ************************************************/


void compile_asm(Prog const& prog) {
    check_executable_exists(NASM);

    // Ask to remove the object file if it already exists
    if (file_exists(prog.obj_name) && !HAS_FORCE(prog.commands)) {
        cout << "Object file exists: " << prog.obj_name << endl;
        ask_rm_file(prog.obj_name);
    }

    vector<string> nasm_args = {
        NASM, "-f", "elf64", prog.src_name, "-o", prog.obj_name};

    int code;

    if ((code = easy_execute(nasm_args).exitstatus))
        die(code, "Could not create object file:", prog.obj_name);

    if (HAS_COMPILE(prog.commands)) {
        check_executable_exists(LD);
        vector<string> ld_args = {LD, prog.obj_name, "-o", prog.bin_name};
        if ((code = easy_execute(ld_args).exitstatus))
            die(code, "Could not link object file:", prog.obj_name);
    }
}


void compile_c(Prog const& prog) {
    check_executable_exists(GCC);

    vector<string> compile_args = {
        "-xc", "-std=c11", "-O3", "-Wall", "-Werror"};

    vector<string> gcc_args = {
        GCC, prog.src_name, "-o", prog.bin_name};
    vector<string> gcc_assemble_args = {
        GCC, prog.src_name, "-o", prog.obj_name, "-c"};
    vector<string> gcc_link_args = {
        GCC, prog.obj_name, "-o", prog.bin_name};

    gcc_args.insert(
        gcc_args.begin()+1, compile_args.begin(), compile_args.end());
    gcc_assemble_args.insert(
        gcc_assemble_args.begin()+1, compile_args.begin(), compile_args.end());

    string lib_flags = string(getenv("C_SEARCH_LIBS"));
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gcc_args, libs);
        append(gcc_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(prog.commands)) {
        if ((code = easy_execute(gcc_assemble_args).exitstatus))
            die(code, "Could not assemble infile:", prog.src_name);
        if (HAS_COMPILE(prog.commands))
            if ((code = easy_execute(gcc_link_args).exitstatus))
                die(code, "Could not compile infile:", prog.src_name);
    } else {
        if ((code = easy_execute(gcc_args).exitstatus))
            die(code, "Could not compile infile:", prog.src_name);
    }
}


void compile_cpp(Prog const& prog) {
    check_executable_exists(GPP);

    vector<string> compile_args = {
        "-xc++", "-std=c++17", "-O3", "-Wall", "-Werror"};

    vector<string> gpp_args = {
        GPP, prog.src_name, "-o", prog.bin_name};
    vector<string> gpp_assemble_args = {
        GPP, prog.src_name, "-o", prog.obj_name, "-c"};
    vector<string> gpp_link_args = {
        GPP, prog.obj_name, "-o", prog.bin_name};

    gpp_args.insert(
        gpp_args.begin()+1, compile_args.begin(), compile_args.end());
    gpp_assemble_args.insert(
        gpp_assemble_args.begin()+1, compile_args.begin(), compile_args.end());

    string lib_flags = getenv("CPLUS_SEARCH_LIBS");
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gpp_args, libs);
        append(gpp_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(prog.commands)) {
        if ((code = easy_execute(gpp_assemble_args).exitstatus))
            die("Could not assemble infile:", prog.src_name);
        if (HAS_COMPILE(prog.commands))
            if ((code = easy_execute(gpp_link_args).exitstatus))
                die(code, "Could not compile infile:", prog.src_name);
    } else {
        if ((code = easy_execute(gpp_args).exitstatus))
            die(code, "Could not compile infile:", prog.src_name);
    }
}


/*************************************************
 * Main
 ************************************************/


int main(int argc, char *argv[]) {
    Prog prog;
    prog.parse_args(argc, argv);

    int exitstatus = 0;

    // Compile the program
    if (HAS_ASSEMBLE(prog.commands) || HAS_COMPILE(prog.commands)) {
        // Ask to remove the outfile if it already exists
        if (file_exists(prog.bin_name) && !HAS_FORCE(prog.commands)) {
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

    // Execute the program
    if (HAS_EXECUTE(prog.commands)) {
        if (!file_exists(prog.bin_name))
            die("No such file or directory:", prog.bin_name);
        if (!file_executable(prog.bin_name))
            die("Permission denied:", prog.bin_name);

        exitstatus = easy_execute(prog.exec_args).exitstatus;
    }

    // Remove the generated files
    if (HAS_REMOVE(prog.commands)) {
        rm(prog.bin_name);
        if (prog.lang == LANG_ASM)
            rm(prog.obj_name);
    }

    return exitstatus;
}
