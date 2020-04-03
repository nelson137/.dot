#include "to.hpp"


string LANG_NAMES[] = { "NoLang", "ASM", "C", "C++" };


static vector<string> include_args() {
    vector<string> include_paths =
        split(safe_getenv("CPLUS_INCLUDE_PATH"), ":");
    for (unsigned i=0; i<include_paths.size(); i++)
        include_paths[i] = "-I" + include_paths[i];
    return include_paths;
}


static vector<string> library_args() {
    vector<string> library_paths = split(safe_getenv("LIBRARY_PATH"), ":");
    for (unsigned i=0; i<library_paths.size(); i++)
        library_paths[i] = "-L" + library_paths[i];
    return library_paths;
}


static bool can_find_lib(string name) {
    vector<string> args = {"/usr/bin/ld", "-o", "/dev/null", name};
    append(args, include_args());
    append(args, library_args());
    return easy_execute(args, true).exitstatus == 0;
}


static vector<string> can_find_libs(vector<string> libs) {
    vector<string> found_libs;
    copy_if(libs.begin(), libs.end(), back_inserter(found_libs), can_find_lib);
    return found_libs;
}


void To::auto_bin_name() {
    this->bin_name = this->src_name[0] == '/' ? "" : "./";
    this->bin_name += this->src_name + ".to";
}


void To::set_lang(string lang) {
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


void To::auto_lang() {
    size_t pos = this->src_name.rfind(".");
    string lang;
    if (pos != string::npos)
        lang = this->src_name.substr(pos+1);
    this->set_lang(lang);
}


void To::compile_asm() {
    // Ask to remove the object file if it already exists
    if (file_exists(this->obj_name) && !HAS_FORCE(this->commands)) {
        cout << "Object file exists: " << this->obj_name << endl;
        ask_rm_file(this->obj_name);
    }

    vector<string> nasm_args = {
        NASM, "-f", "elf64", this->src_name, "-o", this->obj_name};

    int code;

    if ((code = easy_execute(nasm_args)))
        die(code, "Could not create object file:", this->obj_name);

    if (HAS_COMPILE(this->commands)) {
        vector<string> ld_args = {LD, this->obj_name, "-o", this->bin_name};
        if ((code = easy_execute(ld_args)))
            die(code, "Could not link object file:", this->obj_name);
    }
}


void To::compile_c() {
    vector<string> compile_args = {
        "-xc", "-std=c11", "-O3", "-Wall", "-Werror"};

    vector<string> gcc_args = {
        GCC, this->src_name, "-o", this->bin_name};
    vector<string> gcc_assemble_args = {
        GCC, this->src_name, "-o", this->obj_name, "-c"};
    vector<string> gcc_link_args = {
        GCC, this->obj_name, "-o", this->bin_name};

    gcc_args.insert(
        gcc_args.begin()+1, compile_args.begin(), compile_args.end());
    gcc_assemble_args.insert(
        gcc_assemble_args.begin()+1, compile_args.begin(), compile_args.end());

    string lib_flags = safe_getenv("C_SEARCH_LIBS");
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gcc_args, libs);
        append(gcc_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(this->commands)) {
        if ((code = easy_execute(gcc_assemble_args)))
            die(code, "Could not assemble infile:", this->src_name);
        if (HAS_COMPILE(this->commands))
            if ((code = easy_execute(gcc_link_args)))
                die(code, "Could not compile infile:", this->src_name);
    } else {
        if ((code = easy_execute(gcc_args)))
            die(code, "Could not compile infile:", this->src_name);
    }
}


void To::compile_cpp() {
    vector<string> compile_args = {
        "-xc++", "-std=c++17", "-O3", "-Wall", "-Werror"};

    vector<string> gpp_args = {
        GPP, this->src_name, "-o", this->bin_name};
    vector<string> gpp_assemble_args = {
        GPP, this->src_name, "-o", this->obj_name, "-c"};
    vector<string> gpp_link_args = {
        GPP, this->obj_name, "-o", this->bin_name};

    gpp_args.insert(
        gpp_args.begin()+1, compile_args.begin(), compile_args.end());
    gpp_assemble_args.insert(
        gpp_assemble_args.begin()+1, compile_args.begin(), compile_args.end());

    string lib_flags = safe_getenv("C_SEARCH_LIBS");
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gpp_args, libs);
        append(gpp_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(this->commands)) {
        if ((code = easy_execute(gpp_assemble_args)))
            die("Could not assemble infile:", this->src_name);
        if (HAS_COMPILE(this->commands))
            if ((code = easy_execute(gpp_link_args)))
                die(code, "Could not compile infile:", this->src_name);
    } else {
        if ((code = easy_execute(gpp_args)))
            die(code, "Could not compile infile:", this->src_name);
    }
}


int To::run(int argc, char *argv[]) {
    To to;
    to.parse(argc, argv);

    int exitstatus = 0;

    if (to.should_compile())
        to.compile();

    if (to.should_execute())
        exitstatus = to.execute();

    if (to.should_remove())
        to.remove();

    return exitstatus;
}


void To::parse(int argc, char *argv[]) {
    this->commands = 0;
    this->lang = NO_LANG;
    bool show_help = false;

    queue<string> pos_args;

    string arg;
    for (int i=1; i<argc; i++) {
        arg = string(argv[i]);

        if (arg == "-h" || arg == "--help")
            show_help = true;
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
            default:  die("Command not recognized:", string(1, c));  break;
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


bool To::should_compile() {
    return HAS_ASSEMBLE(this->commands) || HAS_COMPILE(this->commands);
}


bool To::should_execute() {
    return HAS_EXECUTE(this->commands);
}


bool To::should_remove() {
    return HAS_REMOVE(this->commands);
}


void To::compile() {
    // Ask to remove the outfile if it already exists
    if (file_exists(this->bin_name) && !HAS_FORCE(this->commands)) {
        cout << "Outfile exists: " << this->bin_name << endl;
        ask_rm_file(this->bin_name);
    }

    switch(this->lang) {
        case LANG_ASM: this->compile_asm(); break;
        case LANG_C:   this->compile_c  (); break;
        case LANG_CPP: this->compile_cpp(); break;
        default:
            die("Compilation not implemented for", LANG_NAMES[this->lang]);
    }
}


int To::execute() {
    if (!file_exists(this->bin_name))
        die("No such file or directory:", this->bin_name);
    if (!file_executable(this->bin_name))
        die("Permission denied:", this->bin_name);

    return easy_execute(this->exec_args).exitstatus;
}


void To::remove() {
    rm(this->bin_name);
    if (this->lang == LANG_ASM)
        rm(this->obj_name);
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


void usage() {
    cerr << USAGE << endl;
    cerr << "See `to --help` for more information" << endl;
    die();
}
