# Python → Cython → C → WebAssembly → TypeScript Pipeline Guide

This guide demonstrates the complete pipeline using a simple "Hello World" example that creates markdown files with timestamps.

## Prerequisites

```bash
# Install required packages
pip install cython --break-system-packages
pip install setuptools --break-system-packages

# For WebAssembly compilation (Emscripten)
# Download from: https://emscripten.org/docs/getting_started/downloads.html
```

---

## Step 1: Python Script (hello_world.py)

**Goal:** Write the initial Python implementation

```python
from datetime import datetime

def create_hello_world_file():
    """
    Creates a markdown file with 'Hello World' and a timestamp.
    Returns the filename created.
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"hello_world_{timestamp}.md"
    
    content = f"""# Hello World

Generated at: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

**Message:** Hello World!
"""
    
    with open(filename, 'w') as f:
        f.write(content)
    
    return filename

if __name__ == "__main__":
    created_file = create_hello_world_file()
    print(f"Created file: {created_file}")
```

**Run:**
```bash
python hello_world.py
```

---

## Step 2: Convert to Cython (hello_world.pyx)

**Goal:** Optimize with Cython type declarations and prepare for C compilation

```cython
# hello_world.pyx
from datetime import datetime

def create_hello_world_file():
    """
    Creates a markdown file with 'Hello World' and a timestamp.
    Returns the filename created.
    """
    cdef str timestamp
    cdef str filename
    cdef str content
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"hello_world_{timestamp}.md"
    
    content = f"""# Hello World

Generated at: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

**Message:** Hello World!
"""
    
    with open(filename, 'w') as f:
        f.write(content)
    
    return filename

def hello_world_wrapper():
    """
    Simple wrapper for WebAssembly compatibility
    """
    return create_hello_world_file()
```

**Key Differences:**
- `.pyx` extension (Cython source file)
- `cdef` for C-level variable declarations
- Type hints for performance optimization

---

## Step 3: Create Setup Script (setup.py)

**Goal:** Configure Cython compilation

```python
from setuptools import setup, Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        "hello_world_cy",
        ["hello_world.pyx"],
        extra_compile_args=['-O3'],
    )
]

setup(
    name="HelloWorldCython",
    ext_modules=cythonize(
        extensions,
        compiler_directives={
            'language_level': "3",
            'embedsignature': True,
        }
    ),
)
```

**Build Cython Extension:**
```bash
python setup.py build_ext --inplace
```

This generates:
- `hello_world.c` - C source code
- `hello_world_cy.*.so` - Compiled Python extension

---

## Step 4: Compile Cython to C

**Goal:** Generate human-readable C code

```bash
# Compile .pyx to .c without building the extension
cython hello_world.pyx --embed
```

This creates `hello_world.c` which can be inspected and used independently.

**View the generated C code:**
```bash
head -50 hello_world.c
```

---

## Step 5: Compile C to WebAssembly with Emscripten

**Goal:** Create a .wasm module usable in browsers/Node.js

### 5.1: Install Emscripten

```bash
# Download and install Emscripten SDK
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

### 5.2: Create WebAssembly-Compatible C Wrapper

Create `hello_world_wasm.c`:

```c
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
```

### 5.3: Compile to WebAssembly

```bash
emcc hello_world_wasm.c \
    -o hello_world.js \
    -s EXPORTED_FUNCTIONS='["_create_hello_world","_malloc","_free"]' \
    -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]' \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='HelloWorldModule' \
    -s ENVIRONMENT='web,node' \
    -O3
```

This generates:
- `hello_world.wasm` - WebAssembly binary
- `hello_world.js` - JavaScript glue code

---

## Step 6: Create TypeScript Interface

**Goal:** Use the WebAssembly module from TypeScript

### 6.1: Create Type Definitions (hello_world.d.ts)

```typescript
// hello_world.d.ts
export interface HelloWorldModule {
    ccall: (
        funcName: string,
        returnType: string,
        argTypes: string[],
        args: any[]
    ) => any;
    
    cwrap: (
        funcName: string,
        returnType: string,
        argTypes: string[]
    ) => (...args: any[]) => any;
}

declare function HelloWorldModule(): Promise<HelloWorldModule>;
export default HelloWorldModule;
```

### 6.2: Create TypeScript Wrapper (index.ts)

```typescript
// index.ts
import HelloWorldModule from './hello_world';

async function main() {
    // Load the WebAssembly module
    const module = await HelloWorldModule();
    
    // Wrap the C function for easy calling
    const createHelloWorld = module.cwrap(
        'create_hello_world',  // C function name
        'string',              // return type
        []                     // no arguments
    );
    
    // Call the function
    const filename = createHelloWorld();
    console.log(`Created file: ${filename}`);
    
    return filename;
}

// Run the example
main().catch(console.error);

// Export for use in other modules
export { main as createHelloWorldFile };
```

### 6.3: Create package.json

```json
{
  "name": "hello-world-wasm",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  }
}
```

### 6.4: Create tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "moduleResolution": "node",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### 6.5: Run TypeScript Code

```bash
# Install dependencies
npm install

# Compile TypeScript
npm run build

# Run the compiled JavaScript
npm start
```

---

## Complete File Structure

```
project/
├── hello_world.py          # Step 1: Original Python script
├── hello_world.pyx         # Step 2: Cython version
├── setup.py                # Step 3: Cython build config
├── hello_world.c           # Step 4: Generated C code
├── hello_world_wasm.c      # Step 5: WebAssembly C wrapper
├── hello_world.wasm        # Step 5: Compiled WebAssembly
├── hello_world.js          # Step 5: JS glue code
└── typescript/
    ├── src/
    │   ├── index.ts        # Step 6: TypeScript implementation
    │   └── hello_world.d.ts # Step 6: Type definitions
    ├── package.json
    └── tsconfig.json
```

---

## Performance Comparison

| Stage | Language | Approximate Speed |
|-------|----------|-------------------|
| Python | Pure Python | 1x (baseline) |
| Cython | Python + C types | 2-10x faster |
| C | Pure C | 10-100x faster |
| WebAssembly | Binary format | Near-native (similar to C) |

---

## Key Advantages of Each Step

### Python
✅ Rapid development
✅ Easy to read and maintain
✅ Extensive libraries

### Cython
✅ Gradual optimization
✅ C performance with Python syntax
✅ Easy interop with Python libraries

### C
✅ Full control over memory
✅ Maximum performance
✅ Portable

### WebAssembly
✅ Runs in browsers
✅ Near-native performance
✅ Sandboxed security
✅ Language-agnostic

---

## Common Issues & Solutions

### Issue 1: Cython compilation fails
```bash
# Solution: Ensure you have a C compiler
sudo apt-get install build-essential  # Ubuntu/Debian
```

### Issue 2: Emscripten not found
```bash
# Solution: Source the environment
source /path/to/emsdk/emsdk_env.sh
```

### Issue 3: TypeScript module not found
```bash
# Solution: Add proper paths in tsconfig.json
"paths": {
    "*": ["./src/*"]
}
```

---

## Next Steps

1. **Profile Performance**: Use `cProfile` (Python) and browser DevTools (WASM)
2. **Add Complexity**: Implement actual algorithms (sorting, searching, etc.)
3. **Optimize Further**: Use Cython decorators like `@cython.boundscheck(False)`
4. **Test in Browser**: Create an HTML page that loads the WASM module
5. **Bundle for Production**: Use webpack or vite for TypeScript/WASM bundling

---

## Resources

- **Cython Documentation**: https://cython.readthedocs.io/
- **Emscripten Docs**: https://emscripten.org/docs/
- **WebAssembly**: https://webassembly.org/
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/

---

*This pipeline demonstrates the journey from high-level Python to low-level WebAssembly, maintaining functionality while gaining performance.*
