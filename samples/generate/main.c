#include <assert.h>
#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

typedef struct source_t {
    char     *source_path;
    unsigned  depth;
} source_t;

typedef struct directory_t directory_t;

typedef void (*dir_callback_t)(const directory_t *entry);
typedef void (*src_callback_t)(const source_t *file);

struct directory_t {
    char        *pathname;
    unsigned     depth;

    unsigned     n_sources;
    source_t    *sources;       /* [0..n_sources) */

    unsigned     n_directories;
    directory_t *directories;   /* [0..n_directories) */
};

static const char makefile_recursive_name[] = "Makefile";
unsigned  arg_verbose;
unsigned  arg_dry_run;
int       arg_subdirs;
int       arg_depth;
int       arg_sources;
char     *arg_root;

static void
validate_arguments(void)
{
    unsigned error = 0;

    if (arg_subdirs <= 0) {
        ++error;
        fprintf(stderr, "Maximum subdirectories per level must be > 0.\n");
    }

    if (arg_depth <= 2) {
        ++error;
        fprintf(stderr, "Maximum subdirectory depth must be > 2.\n");
    }

    if (arg_sources <= 0) {
        ++error;
        fprintf(stderr, "Maximum sources per subdirectory must be > 0.\n");
    }

    if (error) {
        exit(-1);
    }
}


static unsigned random_in_range(int upper_bound)
{
    int r;
    assert(upper_bound <= RAND_MAX);

    return (unsigned)(rand() % upper_bound);
}


static directory_t *allocate_directory(unsigned n)
{
    const unsigned  n_bytes = sizeof(directory_t) * n;
    directory_t    *d       = malloc(n_bytes);

    assert(d);
    memset(d, '\0', n_bytes);
    return d;
}


static source_t *allocate_source(unsigned n)
{
    const unsigned  n_bytes = sizeof(source_t) * n;
    source_t       *s       = malloc(n_bytes);
    assert(s);

    memset(s, '\0', n_bytes);
    return s;
}

static char *
create_lmsbw_config_name(const char *pathname, unsigned number)
{
    const char suffix[]    = ".cfg";
    int           r;
    char         *result;
    char          buf[32];
    size_t        allocation_size;
    const size_t  buf_size = sizeof(buf) / sizeof(buf[0]);

    r = snprintf(buf, buf_size, "%u", number);
    assert(r < buf_size - 1);

    allocation_size = (strlen(pathname) +
                       1              +   /* / */
                       strlen(buf)    +   /* number */
                       strlen(suffix) +   /* suffix */
                       1);                /* '\0' */
    result = malloc(allocation_size);

    assert(result);
    r = snprintf(result, allocation_size, "%s/%u%s",
                 pathname, number, suffix);
    result[allocation_size - 1] = '\0';
    assert(r <= allocation_size);
    return result;
}

static char *
create_path(const char *parent_path,
            const char *prefix,
            const char *suffix,
            unsigned    number)
{
    int           r;
    char         *result;
    char          buf[32];
    size_t        allocation_size;
    const size_t  buf_size = sizeof(buf) / sizeof(buf[0]);

    r = snprintf(buf, buf_size, "%u", number);
    assert(r < buf_size - 1);

    allocation_size = (strlen(parent_path) +
                       1              +   /* / */
                       strlen(prefix) +   /* prefix */
                       strlen(buf)    +   /* number */
                       strlen(suffix) +   /* suffix */
                       1);                /* '\0' */
    result = malloc(allocation_size);

    assert(result);
    r = snprintf(result, allocation_size, "%s/%s%u%s",
                 parent_path, prefix, number, suffix);
    result[allocation_size - 1] = '\0';
    assert(r <= allocation_size);
    return result;
}


static void
indent(unsigned depth)
{
    unsigned i;
    for (i = 0; i < depth; ++i) {
        printf("  ");
    }
}

static void
dump_directory(const directory_t *dir, unsigned depth)
{
    unsigned i;
    indent(depth);
    printf("%s  dirs: %u  sources: %u\n",
           dir->pathname, dir->n_directories, dir->n_sources);

    for (i = 0; i < dir->n_directories; ++i) {
        dump_directory(&dir->directories[i], depth + 1);
    }
    for (i = 0; i < dir->n_sources; ++i) {
        indent(depth + 1);
        printf("%s\n", dir->sources[i].source_path);
    }
}

static void makefile_generate_list_of_subdirectories(FILE *fp,
                                                     const directory_t *dir)
{
    unsigned i;

    for (i = 0; i < dir->n_directories; ++i) {
        fprintf(fp, "$(notdir %s) ", dir->directories[i].pathname);
    }
}

static void makefile_generate_list_of_executables(FILE *fp,
                                                  const directory_t *dir)
{
    unsigned i;

    for (i = 0; i < dir->n_sources; ++i) {
        fprintf(fp, "s%u ", i);
    }
}

static void makefile_generate_phony(FILE *fp, const directory_t *dir)
{
    fprintf(fp, ".PHONY:\t");
    makefile_generate_list_of_subdirectories(fp, dir);
    fprintf(fp, "\n\n");
}

static void makefile_generate_executables_macro(FILE *fp,
                                                const directory_t *dir)
{
    fprintf(fp, "EXECUTABLES\t=\t");
    makefile_generate_list_of_executables(fp, dir);
    fprintf(fp, "\n\n");
}


static void makefile_generate_subdirs_macro(FILE *fp, const directory_t *dir)
{
    fprintf(fp, "SUBDIRS\t=\t");
    makefile_generate_list_of_subdirectories(fp, dir);
    fprintf(fp, "\n\n");
}

static void makefile_generate_header(FILE *fp)
{
    fprintf(fp, "# Makefile\n\n");
}

static void makefile_generate_all(FILE *fp, const directory_t *dir)
{
    fprintf(fp, "all:\t$(SUBDIRS) $(EXECUTABLES)\n\n");
}

static void makefile_generate_clean(FILE *fp, const directory_t *dir)
{
    fprintf(fp, "clean:\t$(SUBDIRS)\n"
            "\trm -f $(EXECUTABLES) *.d"
            "\n\n");
}

static void makefile_generate_install(FILE *fp, const directory_t *dir)
{
    const int perform_real_install = 0;
    if (perform_real_install) {
        fprintf(fp, "install:\t$(SUBDIRS)\n"
                "\t$(if $(EXECUTABLES),"
                "mkdir --parents $(DESTDIR)/usr/bin/%s; "
                "cp $(EXECUTABLES) $(DESTDIR)/usr/bin/%s)\n\n",
                dir->pathname + 1, dir->pathname + 1);
    } else {
        fprintf(fp, "install:\n\n");
    }
}

static void makefile_generate_executables(FILE *fp, const directory_t *dir)
{
    fprintf(fp, "$(EXECUTABLES):\t| $(SUBDIRS)\n\n");
}

static void makefile_generate_subdirs(FILE *fp,
                                      const directory_t *dir,
                                      const char *makefile_name)
{
    fprintf(fp,
            "$(SUBDIRS):\n"
            "\t$(MAKE) -f %s --silent -C $@ $(MAKECMDGOALS)\n\n",
            makefile_name);
}

static void create_recursive_makefile(const directory_t *dir,
                                      const char *makefile_name)
{
    FILE *fp;
    char *mname = malloc(strlen(dir->pathname) +
                         1                     + /* / */
                         strlen(makefile_name) +
                         1);                     /* '\0' */
    assert(mname != NULL);
    sprintf(mname, "%s/%s", dir->pathname, makefile_name);
    printf("Create Makefile for '%s'\n", dir->pathname);
    fp = fopen(mname, "w");
    assert(fp != NULL);
    makefile_generate_header(fp);
    makefile_generate_phony(fp, dir);
    makefile_generate_subdirs_macro(fp, dir);
    makefile_generate_executables_macro(fp, dir);
    makefile_generate_all(fp, dir);
    makefile_generate_install(fp, dir);
    makefile_generate_clean(fp, dir);
    makefile_generate_subdirs(fp, dir, makefile_name);
    makefile_generate_executables(fp, dir);
    fclose(fp);
}

static void traverse_structure(const directory_t *dir,
                               dir_callback_t     dcb,
                               src_callback_t     scb);

static void source_create(const source_t *src);
static void directory_create(const directory_t *dir)
{
    unsigned i;
    int r;

    r = mkdir(dir->pathname,
              S_IRUSR | S_IWUSR | S_IXUSR |
              S_IRGRP | S_IWGRP | S_IXGRP |
              S_IROTH | S_IWOTH | S_IXOTH);
    if (r != 0) {
        printf("Unable to create '%s'\n", dir->pathname);
        perror("mkdir failed");
        exit(-1);
    }
    create_recursive_makefile(dir, makefile_recursive_name);
}

static void source_create(const source_t *src)
{
    FILE *fp;

    fp = fopen(src->source_path, "w");
    assert(fp != NULL);

    fprintf(fp,
            "#include <stdio.h>\n\n"
            "int main(void)\n"
            "{\n"
            "\tprintf(\"%s\\n\");\n"
            "\treturn 0;\n"
            "}\n", src->source_path);
    fclose(fp);
}


static void source_dump(const source_t *src);
static void directory_dump(const directory_t *dir)
{
    unsigned i;
    indent(dir->depth);
    printf("%p %u: %s  dirs: %u  sources: %u\n",
           dir, dir->depth, dir->pathname, dir->n_directories, dir->n_sources);
}

static void source_dump(const source_t *src)
{
    indent(src->depth);
    printf("+ %s\n", src->source_path);
}

static void
traverse_structure(const directory_t *dir,
                   dir_callback_t     dcb,
                   src_callback_t     scb)
{
    unsigned i;

    dcb(dir);
    for (i = 0; i < dir->n_directories; ++i) {
        traverse_structure(&dir->directories[i],
                           dcb, scb);
    }
    for (i = 0; i < dir->n_sources; ++i) {
        scb(&dir->sources[i]);
    }
}

static void dump_structure(const directory_t *dir)
{
    traverse_structure(dir, directory_dump, source_dump);
}

static void create_lmsbw_main_configuration(const directory_t *dir)
{
    const int len = (strlen(dir->pathname)  +
                     1                      + /* '/'  */
                     strlen("generate.cfg") +
                     1);                      /* '\0' */
    char *fname = malloc(len);
    FILE *fp;
    unsigned i;

    assert(fname);
    sprintf(fname, "%s/generate.cfg", dir->pathname);
    fname[len - 1] = '\0';
    fp = fopen(fname, "w");

    fprintf(fp, "define load_configuration\n");
    for (i = 0; i < dir->n_directories; ++i) {
        fprintf(fp, "$(eval include %s/%u.cfg)\n", dir->pathname, i);
    }
    fprintf(fp, "endef\n\n\n");
    fprintf(fp,
            "vv:=$(call set,LMSBW_configuration,load-configuration-function,"
            "load_configuration)\n"
            "vv:=$(call set,LMSBW_configuration,"
            "component-build-support,source)\n\n");

    fclose(fp);
    free(fname);
}

static void create_lmsbw_configuration(const directory_t *dir)
{
    unsigned i;

    for (i = 0; i < dir->n_directories; ++i) {
        char *name = create_lmsbw_config_name(dir->pathname, i);
        FILE *fp = fopen(name, "w");

        assert(fp);
        fprintf(fp,
                "$(call declare_source_component,"
                "d%u,directory %u,image,%s,%s)\n",
                i, i, name, dir->directories[i].pathname);
        free(name);
        fclose(fp);
    }

    create_lmsbw_main_configuration(dir);
}

static void create_source_tree(const directory_t *dir)
{
    traverse_structure(dir, directory_create, source_create);
    create_recursive_makefile(dir, makefile_recursive_name);
    create_lmsbw_configuration(dir);
}

static void
allocate_directories(directory_t *dir, unsigned allow_zero)
{
    unsigned n_directories = random_in_range(arg_subdirs);

    while (!allow_zero && n_directories == 0) {
        n_directories = random_in_range(arg_subdirs);
    }
    dir->n_directories = n_directories;
    dir->directories   = allocate_directory(n_directories);
}


static void
allocate_sources(directory_t *dir)
{
    const unsigned n_sources = random_in_range(arg_sources);
    dir->n_sources           = n_sources;
    dir->sources             = allocate_source(n_sources);
}


static void
create_source(source_t   *source,
              unsigned    source_number,
              const char *parent_name)
{
    source->source_path = create_path(parent_name, "s", ".c", source_number);
}


static void
initialize_directories(directory_t *dir, unsigned depth)
{
    unsigned i;
    for (i = 0; i < dir->n_directories; ++i) {
        dir->directories[i].depth = depth;
    }
}

static void
initialize_sources(directory_t *dir, unsigned depth)
{
    unsigned i;
    for (i = 0; i < dir->n_sources; ++i) {
        dir->sources[i].depth = depth;
        create_source(&dir->sources[i], i, dir->pathname);
    }
}


static void create_subdirectory_tree(directory_t *dir,
                                     const char  *parent_name,
                                     int          depth,
                                     unsigned     directory_number)
{
    if (depth < arg_depth) {
        char     *pathname = create_path(parent_name, "d", "",
                                         directory_number);
        unsigned  i;

        dir->pathname = strdup(pathname);
        if (depth < arg_depth - 1) {
            /* Only allocate directories if they will be present. */
            allocate_directories(dir, 1);
            initialize_directories(dir, depth);
        }
        allocate_sources(dir);
        initialize_sources(dir, depth - 1);

        for (i = 0; i < dir->n_directories; ++i) {
            create_subdirectory_tree(&dir->directories[i],
                                     dir->pathname,
                                     depth + 1,
                                     i);
        }
    }
}

static directory_t *
create_structure(int depth, char *pathname)
{
    directory_t    *dir;
    unsigned        i;

    assert(depth == 0);

    /* Create the root directory descriptor. */
    dir              = allocate_directory(1);
    dir->depth       = 0;
    dir->pathname    = strdup(pathname);

    allocate_directories(dir, 0);
    dir->n_sources = 0;         /* top level directory never has sources */
    dir->sources   = NULL;

    initialize_sources(dir, depth);
    initialize_directories(dir, depth + 1);

    for (i = 0; i < dir->n_directories; ++i) {
         create_subdirectory_tree(&dir->directories[i],
                                  dir->pathname, depth + 2, i);
    }
    return dir;
}


static void
process_arguments(int argc, char *argv[])
{
    static struct option long_options[] = {
        { "verbose",   no_argument      , NULL, 256 },
        { "depth",     required_argument, NULL, 260 },
        { "dry-run",   no_argument      , NULL, 257 },
        { "root",      required_argument, NULL, 258 },
        { "sources",   required_argument, NULL, 261 },
        { "subdirs",   required_argument, NULL, 259 },
        { NULL    ,    no_argument      , NULL, 0   }
    };

    int c;

    while (1) {
        int option_index = 0;
        c = getopt_long(argc, argv, "", long_options, &option_index);

        if (c == -1) {
            break;
        }

        switch (c) {
        case 256:
            arg_verbose = 1;
            break;

        case 257:
            arg_dry_run = 1;
            break;

        case 258:
            arg_root = strdup(optarg);
            break;

        case 259:
            arg_subdirs = atoi(optarg);
            break;

        case 260:
            arg_depth = atoi(optarg);
            break;

        case 261:
            arg_sources = atoi(optarg);
            break;

        default:
            printf("?? getopt returned character code 0%o ??\n", c);
        }
    }
}


int
main(int argc, char *argv[])
{
    directory_t *root;

    srand(time(NULL));
    process_arguments(argc, argv);
    validate_arguments();

    root = create_structure(0, arg_root);
    create_source_tree(root);

    return 0;
}
