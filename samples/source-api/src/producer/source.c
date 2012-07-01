#include <stdio.h>
#include "api.h"

void public_api(sample_struct_t *s)
{
    printf("Hello, API: %p  size: %zu\n", s, sizeof(*s));
}
