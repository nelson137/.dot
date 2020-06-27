#include "to.hpp"


void To::auto_bin_name() {
    this->bin_name = this->src_name[0] == '/' ? "" : "./";
    this->bin_name += this->src_name + ".to";
}


void To::set_lang(string lang) {
    transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
    if (lang == "s" || lang == "asm" || lang == "assembly") {
        string obj_name = this->src_name + ".o";
        this->build_steps.emplace_back(
            obj_name,
            list<string>{ NASM, "-f", "elf64", "-o", obj_name });
        this->build_steps.emplace_back(
            this->bin_name,
            list<string>{ LD, "-o", this->bin_name });
    } else if (lang == "c") {
        this->build_steps.emplace_back(
            this->bin_name,
            list<string>{ GCC, "-xc", C_ARGS, "-o", this->bin_name });
    } else if (lang == "cpp" || lang == "c++") {
        this->build_steps.emplace_back(
            this->bin_name,
            list<string>{ GPP, "-xc++", C_ARGS, "-o", this->bin_name });
    } else {
        die("Language not recognized:", lang);
    }
}


void To::auto_lang() {
    size_t pos = this->src_name.rfind(".");
    string lang;
    if (pos != string::npos)
        lang = this->src_name.substr(pos+1);
    this->set_lang(lang);
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

    // Determine the binary filename if it wasn't specified by the user
    if (this->bin_name.empty())
        this->auto_bin_name();

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

    bool force = HAS_FORCE(this->commands);
    list<BuildStep>::iterator it = this->build_steps.begin();

    string of = it->perform_step(this->src_name, force);
    this->intermediate_files.push_back(of);

    for (it++; it!=this->build_steps.end(); it++)
        this->intermediate_files.push_back(
            it->perform_step(this->intermediate_files.back(), force));
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
    for (const string& fn : this->intermediate_files)
        rm(fn);
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
    puts("  c            Compile the program and generate an executable");
    puts("  d            Print the commands that would be executed,");
    puts("               output is suitable for use in a shell");
    puts("  e            Run the generated executable");
    puts("  f            Do not prompt before overwriting files");
    puts("  o            Provide a custom name for the executable");
    puts("  r            Remove the executable and all compilation files");
    puts("  x            The language of the infile");
    exit(0);
}


void usage() {
    cerr << USAGE << endl;
    cerr << "See `to --help` for more information" << endl;
    die();
}
