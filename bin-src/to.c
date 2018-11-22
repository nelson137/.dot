#define _DEFAULT_SOURCE

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

#define ARRLEN(x) sizeof(x)/sizeof(x[0])
#define MAX 512

#define COMPILE  1
#define EXECUTE  2
#define REMOVE   4

enum Lang {
    LangUnknown,
    LangASM,
    LangC,
    LangCPP
};

typedef struct {
    int exited;
    int exitstatus;
    int signaled;
    int termsig;
    int coredump;
    int stopped;
    int stopsig;
    int continued;
    char out[MAX];
    char err[MAX];
} PRet;

char *USAGE = "Usage: eo <commands> [--dry-run] [-x LANG] <file>\n";


/*************************************************
 * Utility Functions
 ************************************************/


/**
 * Print an error message to stderr and exit with code 1.
 */
void die(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    exit(1);
}


int isOpt(char *arg) {
    return arg[0] == '-' && strlen(arg) >= 2;
}


int isLongOpt(char *arg) {
    return arg[0] == '-' && arg[1] == '-' && strlen(arg) > 2;
}


int isCompoundOpt(char *arg) {
    return arg[0] == '-' && arg[1] != '-' && strlen(arg) > 2;
}


void print_args(char *args[], int len) {
    for (int i=0; i<len-1; i++)
        printf(
            "%s%s",
            i > 0 ? " " : "",
            args[i]);
    printf("\n");
}


/**
 * Convert the string to lowercase.
 */
char *lower(char *str) {
    for (int i=0; str[i]; i++)
        if ('A' <= str[i] && str[i] <= 'Z')
            str[i] += 32;
    return str;
}


/**
 * Return whether the first string matches any of the following strings.
 */
int strMatchesAny(char *str, char *a, ...) {
    if (strcmp(str, a) == 0)
        return 1;

    va_list strings;
    va_start(strings, a);

    char *arg;
    do {
        arg = va_arg(strings, char*);
        if (arg == NULL)
            break;
        if (strcmp(str, arg) == 0)
            return 1;
    } while (1);

    va_end(strings);

    return 0;
}


/**
 * Return a pointer to the extension of the given filename.
 * Return an empty string if no extension can be determined.
 */
char *getExt(char *fn) {
    char *lastdot = strrchr(fn, '.');
    if (!lastdot || lastdot == fn)
        return "";
    return lastdot + 1;
}


int execute(PRet *ret, char *argv[], int len) {
    // Make sure argv ends with NULL sentinel
    if (argv[len-1] != NULL) {
        strcpy(ret->err, "Last argument of argv must be a null pointer\n");
        return -1;
    }

    int pipes[2][2];

    int *out_pipe = pipes[0];
    int *err_pipe = pipes[1];

    if (pipe(out_pipe) < 0) {
        strcpy(ret->err, "Could not create pipe for stdout\n");
        return -2;
    }

    if (pipe(err_pipe) < 0) {
        strcpy(ret->err, "Could not create pipe for stderr\n");
        return -2;
    }

    int parent_out_fd = out_pipe[0];
    int parent_err_fd = err_pipe[0];
    int child_out_fd = out_pipe[1];
    int child_err_fd = err_pipe[1];

    int pid = fork();

    if (pid == -1) {
        strcpy(ret->err, "Could not fork\n");
        return -3;
    } else if (pid == 0) {
        /**
         * Child
         */

        dup2(child_out_fd, STDOUT_FILENO);
        dup2(child_err_fd, STDERR_FILENO);

        // None of the pipes are needed in the child
        close(parent_out_fd);
        close(parent_err_fd);
        close(child_out_fd);
        close(child_err_fd);

        execv(argv[0], argv);
        _exit(1);
    } else {
        /**
         * Parent
         */

        // Child pipes are not needed in the parent
        close(child_out_fd);
        close(child_err_fd);

        // Wait for child to complete
        int status;
        /* wait(&status); */
        waitpid(pid, &status, 0);

        ret->exited = WIFEXITED(status);
        ret->exitstatus = WEXITSTATUS(status);
        ret->signaled = WIFSIGNALED(status);
        ret->termsig = WTERMSIG(status);
        ret->coredump = WCOREDUMP(status);
        ret->stopped = WIFSTOPPED(status);
        ret->stopsig = WSTOPSIG(status);
        ret->continued = WIFCONTINUED(status);

        int count;
        char out[MAX], err[MAX];

        // Read child's stdout
        count = read(parent_out_fd, out, sizeof(out)-1);
        if (count == -1) {
            strcpy(ret->err, "Could not read child's stdout\n");
            return -4;
        }
        out[count] = '\0';
        strcpy(ret->out, out);

        // Read child's stderr
        count = read(parent_err_fd, err, sizeof(err)-1);
        if (count == -1) {
            strcpy(ret->err, "Could not read child's stderr\n");
            return -4;
        }
        err[count] = '\0';
        strcpy(ret->err, err);

        close(parent_out_fd);
        close(parent_err_fd);
    }

    return 0;
}


/*************************************************
 * Core Functions
 ************************************************/


/**
 * Return the flag corresponding to the language to compile for.
 */
enum Lang determineLang(char *lang) {
    if (strMatchesAny(lang, "s", "asm", "assembly", "x86", "x86_64", NULL))
        return LangASM;
    else if (strMatchesAny(lang, "c", NULL))
        return LangC;
    else if (strMatchesAny(lang, "cpp", "c++", NULL))
        return LangCPP;
    else
        return LangUnknown;
}


/**
 * Return the flag corresponding to the language indicated by the filename.
 */
int autoDetermineLang(char *fn) {
    char *ext = getExt(fn);
    return strcmp(ext, "") == 0 ? LangUnknown : determineLang(ext);
}


/**
 * Compile the program for assembly.
 */
void compile_asm(int dryrun, char *src_name, char *obj_name, char *exe_name) {
    char *nasm_args[] = {
        "/usr/bin/nasm", "-f", "elf64", src_name, "-o", obj_name, NULL};
    int nasm_args_len = ARRLEN(nasm_args);

    char *ld_args[] = {
        "/usr/bin/ld", obj_name, "-o", exe_name, NULL};
    int ld_args_len = ARRLEN(ld_args);

    if (dryrun) {
        print_args(nasm_args, nasm_args_len);
        print_args(ld_args, ld_args_len);
    } else {
        PRet nasm_ret, ld_ret;
        execute(&nasm_ret, nasm_args, nasm_args_len);
        execute(&ld_ret, ld_args, ld_args_len);
    }
}


/**
 * Compile the program for C.
 */
void compile_c(int dryrun, char *src_name, char *exe_name) {
    // Get the cflags for the python library
    PRet pylibs;
    char *pylib_args[] = {
        "/usr/bin/pkg-config", "--cflags", "--libs", "python3", NULL};
    execute(&pylibs, pylib_args, 5);
    if (!pylibs.exited || pylibs.exitstatus != 0)
        die("Could not get cflags for the python3 library\n");

    // Remove trailing newline
    char *nl = strrchr(pylibs.out, '\n');
    if (nl && nl != pylibs.out)
        *nl = '\0';

    // Split the pylibs string
    // Example string: "abc def ghi\0"
    int n = 1;
    for (int i=0; pylibs.out[i]; i++) {
        if (pylibs.out[i] == ' ') {
            n++;
            // Replace each space with '\0'
            pylibs.out[i] = '\0';
        }
    }
    // Example string would now be: "abc\0def\0ghi\0"
    // Fill the flags array with a pointer to each null-terminated segment
    char *pylib_flags[n];
    int pylib_flags_len = n;
    char *pointer = pylibs.out;
    pylib_flags[0] = pointer;
    // array with example string will be: {"abc\0", "def\0", "ghi\0"}
    for (int i=1; i<n; i++) {
        pointer = strchr(pointer, '\0') + 1;
        pylib_flags[i] = pointer;
    }

    char *base_args[] = {
        "/usr/bin/gcc",
        "-std=c11", "-O3", "-Wall", "-Werror",
        src_name, "-o", exe_name,
        "-lm", "-ljson-c", "-lmylib"};
    int base_args_len = ARRLEN(base_args);

    // Combine base_args, pylib_flags, and NULL sentinel
    int args_len = base_args_len + pylib_flags_len + 1;
    char *args[args_len];
    int count = 0;
    for (int i=0; i<base_args_len; i++)
        args[count++] = base_args[i];
    for (int i=0; i<pylib_flags_len; i++)
        args[count++] = pylib_flags[i];
    args[count] = NULL;

    if (dryrun) {
        print_args(args, args_len);
    } else {
        PRet ret;
        execute(&ret, args, args_len);
    }
}


/**
 * Compile the program for C++.
 */
void compile_cpp(int dryrun, char *src_name, char *exe_name) {
    char *args[] = {
        "/usr/bin/g++",
        "-std=c++11", "-O3", "-Wall", "-Werror",
        src_name, "-o", exe_name,
        NULL};
    int args_len = ARRLEN(args);

    if (dryrun) {
        print_args(args, args_len);
    } else {
        PRet ret;
        execute(&ret, args, args_len);
    }
}


/*************************************************
 * Main
 ************************************************/


int main(int orig_argc, char *orig_argv[]) {
    if (orig_argc < 3)
        die(USAGE, orig_argv[0]);

    /**
     * Pre-process arguments
     */

    int argc = 0;
    int parsing_opts = 1;
    for (int i=0; i<orig_argc; i++) {
        if (strcmp(orig_argv[i], "--") == 0)
            parsing_opts = 0;
        else if (parsing_opts && isCompoundOpt(orig_argv[i]))
            argc += strlen(orig_argv[i]) - 2;
        argc++;
    }

    /**
     * Split compound options
     * For example, -abc gets expanded to -a, -b, -c in-place
     * If orig_argv is {"./t", "-abc", "--long", "-def"}, then
     * argv will be {"./t", "-a", "-b", "-c", "--long", "-d", "-e", "-f"}
     */

    char *argv[argc];

    char compoundOpts[argc*3];
    char *coPtr = compoundOpts;
    int argv_i = 0;
    for (int i=0; i<orig_argc; i++) {
        if (isCompoundOpt(orig_argv[i])) {
            for (int j=1; j<strlen(orig_argv[i]); j++) {
                argv[argv_i++] = coPtr;
                *(coPtr++) = '-';
                *(coPtr++) = orig_argv[i][j];
                *(coPtr++) = '\0';
            }
        } else {
            argv[argv_i++] = orig_argv[i];
        }
    }

    /**
     * Parse arguments
     */

    parsing_opts = 1;
    int commands = 0;
    int dryrun = 0;
    char *src_name = NULL;
    int too_many_src_fns = 0;
    char *forced_ext = NULL;

    for (int i=1; i<argc; i++) {
        if (parsing_opts && isOpt(argv[i])) {
            if (strMatchesAny(argv[i], "--", NULL))
                parsing_opts = 0;
            else if (strMatchesAny(argv[i], "-c", "--compile", NULL))
                commands |= COMPILE;
            else if (strMatchesAny(argv[i], "-e", "--execute", NULL))
                commands |= EXECUTE;
            else if (strMatchesAny(argv[i], "-r", "--remove", NULL))
                commands |= REMOVE;
            else if (strMatchesAny(argv[i], "-x", "--language", NULL))
                forced_ext = argv[++i];
            else if (strMatchesAny(argv[i], "--dry-run", NULL))
                dryrun = 1;
            else
                die("%s option not recognized: %s\n",
                    isLongOpt(argv[i]) ? "Long" : "Short",
                    argv[i]);
        } else {
            if (src_name != NULL)
                too_many_src_fns = 1;
            src_name = argv[i];
        }
    }

    /**
     * Error messages and setup
     */

    if (commands == 0)
        die("No commands were given\n");

    if (! (commands & COMPILE))
        die("Program requires compilation\n");

    // None or more than one src_name was given
    if (src_name == NULL || too_many_src_fns)
        die(USAGE, argv[0]);

    // Get the programming language as an integer
    enum Lang lang;
    if (forced_ext == NULL) {
        lang = autoDetermineLang(src_name);
        if (lang == LangUnknown)
            die("Could not determine language from filename: %s\n",
                src_name);
    } else {
        if (strlen(forced_ext) == 0)
            die("Language cannot be empty string\n");
        lang = determineLang(lower(forced_ext));
        if (lang == LangUnknown)
            die("Language not recognized: %s\n", forced_ext);
    }

    // Get the executable filename
    char exe_name[strlen(src_name)+3+1];
    snprintf(exe_name, sizeof(exe_name), "%s.eo", src_name);

    // Get the object file name
    // Only used for ASM
    char obj_name[strlen(exe_name)+2+1];
    snprintf(obj_name, sizeof(obj_name), "%s.o", exe_name);

    /**
     * Execute commands
     */

    if (lang == LangASM)
        compile_asm(dryrun, src_name, obj_name, exe_name);
    else if (lang == LangC)
        compile_c(dryrun, src_name, exe_name);
    else if (lang == LangCPP)
        compile_cpp(dryrun, src_name, exe_name);

    if (commands & EXECUTE) {
        char exe_arg[2+strlen(exe_name)+1];
        snprintf(exe_arg, sizeof(exe_arg), "./%s", exe_name);
        char *exec_args[] = {exe_arg, NULL};
        int exec_args_len = ARRLEN(exec_args);
        if (dryrun) {
            print_args(exec_args, exec_args_len);
        } else {
            PRet exeRet;
            execute(&exeRet, exec_args, exec_args_len);
            printf("%s", exeRet.out);
            fprintf(stderr, "%s", exeRet.err);
        }
    }

    if (commands & REMOVE) {
        int rm_args_len = lang == LangASM ? 4 : 3;
        char *rm_args[rm_args_len];
        int rm_args_i = 0;
        rm_args[rm_args_i++] = "/bin/rm";
        if (lang == LangASM)
            rm_args[rm_args_i++] = obj_name;
        rm_args[rm_args_i++] = exe_name;
        rm_args[rm_args_i] = NULL;

        if (dryrun) {
            print_args(rm_args, rm_args_len);
        } else {
            PRet rmRet;
            execute(&rmRet, rm_args, rm_args_len);
        }
    }

    return 0;
}
