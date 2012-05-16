/*
 * Dummy header for missing getmode/setmode in libc.
 */
mode_t
getmode(const void *bbox, mode_t omode);
void * setmode(const char *p);
