#include <stdio.h>

#define STRING(x)       #x        /* Stringify 'x'. */
#define XSTRING(x)      STRING(x) /* Expand 'x', then stringify. */

int main(void)
{
    printf("Professional Product Executable: " XSTRING(PRODUCT) "\n");
    return 0;
}
