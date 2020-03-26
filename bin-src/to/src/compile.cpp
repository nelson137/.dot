#include "compile.hpp"


vector<string> include_args() {
    vector<string> include_paths =
        split(safe_getenv("CPLUS_INCLUDE_PATH"), ":");
    for (unsigned i=0; i<include_paths.size(); i++)
        include_paths[i] = "-I" + include_paths[i];
    return include_paths;
}


vector<string> library_args() {
    vector<string> library_paths = split(safe_getenv("LIBRARY_PATH"), ":");
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
    copy_if(libs.begin(), libs.end(), back_inserter(found_libs), can_find_lib);
    return found_libs;
}


/**
 * Die and print an error message if the given executable does not exist.
 */
void check_executable_exists(string exe) {
    if (!file_exists(exe))
        die("Executable does not exist:", exe);
}


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

    if ((code = easy_execute(nasm_args)))
        die(code, "Could not create object file:", prog.obj_name);

    if (HAS_COMPILE(prog.commands)) {
        check_executable_exists(LD);
        vector<string> ld_args = {LD, prog.obj_name, "-o", prog.bin_name};
        if ((code = easy_execute(ld_args)))
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

    string lib_flags = safe_getenv("C_SEARCH_LIBS");
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gcc_args, libs);
        append(gcc_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(prog.commands)) {
        if ((code = easy_execute(gcc_assemble_args)))
            die(code, "Could not assemble infile:", prog.src_name);
        if (HAS_COMPILE(prog.commands))
            if ((code = easy_execute(gcc_link_args)))
                die(code, "Could not compile infile:", prog.src_name);
    } else {
        if ((code = easy_execute(gcc_args)))
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

    string lib_flags = safe_getenv("C_SEARCH_LIBS");
    if (lib_flags.size()) {
        vector<string> libs = can_find_libs(split(lib_flags));
        append(gpp_args, libs);
        append(gpp_assemble_args, libs);
    }

    int code;

    if (HAS_ASSEMBLE(prog.commands)) {
        if ((code = easy_execute(gpp_assemble_args)))
            die("Could not assemble infile:", prog.src_name);
        if (HAS_COMPILE(prog.commands))
            if ((code = easy_execute(gpp_link_args)))
                die(code, "Could not compile infile:", prog.src_name);
    } else {
        if ((code = easy_execute(gpp_args)))
            die(code, "Could not compile infile:", prog.src_name);
    }
}
