#include <emscripten.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

// WebAssembly-exported function
EMSCRIPTEN_KEEPALIVE
char* create_hello_world() {
    static char filename[256];
    time_t now = time(NULL);
    struct tm* t = localtime(&now);
    
    // Create filename with timestamp
    snprintf(filename, sizeof(filename), 
             "hello_world_%04d%02d%02d_%02d%02d%02d.md",
             t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
             t->tm_hour, t->tm_min, t->tm_sec);
    
    // Create content
    FILE* f = fopen(filename, "w");
    if (f == NULL) {
        return "Error: Could not create file";
    }
    
    fprintf(f, "# Hello World\n\n");
    fprintf(f, "Generated at: %04d-%02d-%02d %02d:%02d:%02d\n\n",
            t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
            t->tm_hour, t->tm_min, t->tm_sec);
    fprintf(f, "**Message:** Hello World!\n");
    
    fclose(f);
    return filename;
}
