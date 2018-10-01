#define _DEFAULT_SOURCE

#include <json.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <sys/wait.h>

#include <mylib.h>


void print_config_help(void) {
    fprintf(stderr, "The config file must be valid JSON with the following structure:\n");
    fprintf(stderr, "    {\n");
    fprintf(stderr, "      \"<hostname>\": {\n");
    fprintf(stderr, "        \"username\": \"<username>\"\n");
    fprintf(stderr, "        \"internal_addr\": \"<internal address>\"\n");
    fprintf(stderr, "        \"external_addr\": \"<external address>\"\n");
    fprintf(stderr, "      },\n");
    fprintf(stderr, "      ...\n");
    fprintf(stderr, "    }\n");
    fprintf(stderr, "Both an internal and external address do not have to be specified, but at least one must\n");
}


void attempt_ssh(const char *uname, const char *addr) {
    size_t size = snprintf(NULL, 0, "%s@%s", uname, addr) + 1;
    char *host = malloc(size);
    snprintf(host, size, "%s@%s", uname, addr);

    int ret;
    int pid = fork();
    if (pid < 0) {
        // fork() failed
        perror("fork failure");
        exit(1);
    } else if (pid == 0) {
        // Executes in child process
        execl("/usr/bin/ssh", "ssh", "-o", "ConnectTimeout=5", host, (char*)NULL);
        _exit(1);
    } else {
        // Executes in parent process
        // Wait for exec to complete
        wait(&ret);
    }
}


char *get_home(void) {
    char *home;

    // Check $HOME variable
    home = getenv("HOME");
    if (home != NULL && strcmp(home,"") != 0)
        return home;

    // Check password entry for user
    struct passwd *pd = getpwuid(getuid());
    return pd->pw_dir;
}


char *get_type_name(json_type type) {
    switch (type) {
        case json_type_null:
            return "null";
        case json_type_boolean:
            return "boolean";
        case json_type_double:
            return "double";
        case json_type_int:
            return "int";
        case json_type_object:
            return "object";
        case json_type_array:
            return "array";
        default:  // json_type_string
            return "string";
    }
}


char *get_type_preposition(json_type type) {
    switch (type) {
        case json_type_boolean:
        case json_type_double:
        case json_type_string:
            return "a ";
        case json_type_int:
        case json_type_array:
        case json_type_object:
            return "an ";
        default:  // json_type_null
            return "";
    }
}


int main (void) {
    char *home = get_home();
    char conf_fn[strlen(home)+9];
    sprintf(conf_fn, "%s/.lsshrc", home);

    // Make sure config file exists
    if (access(conf_fn, F_OK) == -1) {
        printf("Config file %s does not exist\n", conf_fn);
        return 1;
    }

    // Make sure config file can be read
    if (access(conf_fn, R_OK) == -1) {
        printf("Cannot read config file %s\n", conf_fn);
        return 1;
    }

    // Open the config file
    FILE *conf_fp = fopen(conf_fn, "r");
    if (conf_fp == NULL) {
        fprintf(stderr, "Cannot open config file %s", conf_fn);
        return 1;
    }

    // Read the config file
    char *raw_config = NULL;
    size_t len;
    ssize_t read = getdelim(&raw_config, &len, '\0', conf_fp);
    if (read == -1) {
        fprintf(stderr, "Cannot read config file %s\n", conf_fn);
        return 1;
    }

    // Close the config file
    fclose(conf_fp);

    // Parse contents into json_object
    enum json_tokener_error err;
    json_object *config = json_tokener_parse_verbose(raw_config, &err);

    // Parsing JSON was not successful
    if (err != json_tokener_success) {
        fprintf(stderr, "Error while parsing config file %s\n\n", conf_fn);
        print_config_help();
        return 1;
    }

    // Number of children in config
    int nc = json_object_object_length(config);

    const char *hostnames[nc], *unames[nc], *int_addrs[nc], *ext_addrs[nc];
    const char *val_s;
    json_type attrs_t, val_t;
    int is_empty, has_uname, has_addr;

    // For each hostname, attrs in config
    int i = 0;
    json_object_object_foreach(config, hn, attrs) {
        // Type of attrs
        attrs_t = json_object_get_type(attrs);

        // attrs is not an object
        if (attrs_t != json_type_object) {
            char *fmt = "Value of host \"%s\" is of type %s when %s%s was expected\n\n";
            // String of type
            char *t_name = get_type_name(attrs_t);
            // String of preposition for expected_type
            char *e_t_prep = get_type_preposition(json_type_object);
            // String of expected type
            char *e_t_name = get_type_name(json_type_object);
            fprintf(stderr, fmt, hn, t_name, e_t_prep, e_t_name);
            print_config_help();
            return 1;
        }

        hostnames[i] = hn;
        has_uname = 0;
        has_addr = 0;

        // For each key, val in hostname
        json_object_object_foreach(attrs, key, val) {
            // Type of val
            val_t = json_object_get_type(val);

            // val is not a string
            if (val_t != json_type_string) {
                char *fmt = "Value of key \"%s\" of host \"%s\" is of type %s when %s%s was expected\n\n";
                // String of type
                char *t_name = get_type_name(val_t);
                // String of preposition for expected_type
                char *e_t_prep = get_type_preposition(json_type_object);
                // String of expected type
                char *e_t_name = get_type_name(json_type_object);
                fprintf(stderr, fmt, key, hn, t_name, e_t_prep, e_t_name);
                print_config_help();
                return 1;
            }

            // The value of the key as a string
            val_s = json_object_get_string(val);
            // Whether or not val_s == ""
            is_empty = (strcmp(val_s, "") == 0);

            if (strcmp(key, "username") == 0) {
                unames[i] = val_s;
                has_uname = !is_empty;
            } else if (strcmp(key, "internal_addr") == 0) {
                int_addrs[i] = val_s;
                has_addr |= !is_empty;
            } else if (strcmp(key, "external_addr") == 0) {
                ext_addrs[i] = val_s;
                has_addr |= !is_empty;
            } else {
                // Unrecognized key in host
            }
        }

        if (!has_uname) {
            fprintf(stderr, "Host %s does not have the required key username\n", hn);
            fprintf(stderr, "Config file: %s\n\n", conf_fn);
            print_config_help();
            return 1;
        }

        if (!has_addr) {
            fprintf(stderr, "Host %s has neither an internal_addr nor an external_addr key. One is required\n\n", hn);
            print_config_help();
            return 1;
        }

        i++;
    }

    // Run listbox with each hostname as a choice
    int choice = listbox(1, "Connect:", (char**)hostnames, nc, "*");
    if (choice == -1)
        return 0;

    const char *addr;
    if (strcmp(int_addrs[choice], "") == 0) {
        // There is no internal addr
        addr = ext_addrs[choice];
    } else if (strcmp(ext_addrs[choice], "" ) == 0) {
        // There is no external addr
        addr = int_addrs[choice];
    } else {
        // There is both an internal and external addr
        printf("\n");
        // Run listbox with internal and external as choices
        char *choices[2] = {"Internal", "External"};
        const char *values[2] = {int_addrs[choice], ext_addrs[choice]};
        int choice2 = listbox(0, "Host Location:", choices, 2, "*");
        if (choice2 == -1)
            return 0;
        addr = values[choice2];
    }

    printf("\n");

    // Try to ssh to the chosen host
    attempt_ssh(unames[choice], addr);

    return 0;
}
