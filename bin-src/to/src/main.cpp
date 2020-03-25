#include "main.hpp"


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
            default:
                die("Compilation not implemented for", LANG_NAMES[prog.lang]);
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
