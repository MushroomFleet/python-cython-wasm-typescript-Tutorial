# Hello World Pipeline: Python → Cython → C → WebAssembly → TypeScript

A complete demonstration of the modern performance optimization pipeline, from high-level Python to near-native WebAssembly.

## 🎯 Quick Start

### Run the Complete Demo

```bash
./build_pipeline.sh
```

This will execute all steps that don't require external tools (Emscripten).

### Step-by-Step Manual Execution

#### 1. Python (Baseline)
```bash
python3 hello_world.py
```

#### 2. Cython Compilation
```bash
# Install Cython
pip3 install cython --break-system-packages

# Compile to C
cython hello_world.pyx --embed
```

#### 3. WebAssembly Compilation (requires Emscripten)
```bash
# First, install Emscripten SDK
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

# Compile C to WebAssembly
emcc hello_world_wasm.c \
  -o hello_world.js \
  -s EXPORTED_FUNCTIONS='["_create_hello_world","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]' \
  -s MODULARIZE=1 \
  -s EXPORT_NAME='HelloWorldModule' \
  -s ENVIRONMENT='web,node' \
  -O3
```

#### 4. TypeScript Usage
```bash
cd typescript
npm install
npm run build
npm start
```

## 📁 Project Structure

```
.
├── README.md                    # This file
├── PIPELINE_GUIDE.md            # Comprehensive guide
├── build_pipeline.sh            # Automated build script
│
├── hello_world.py               # Step 1: Python original
├── hello_world.pyx              # Step 2: Cython version
├── setup.py                     # Cython build config
├── hello_world_generated.c      # Step 3: Generated C code
│
├── hello_world_wasm.c           # Step 4: WebAssembly C wrapper
├── hello_world.wasm             # Compiled WebAssembly (after emcc)
├── hello_world.js               # JS glue code (after emcc)
│
└── typescript/                  # Step 5: TypeScript integration
    ├── src/
    │   ├── index.ts
    │   └── hello_world.d.ts
    ├── package.json
    └── tsconfig.json
```

## 🚀 What This Demonstrates

### The Pipeline Flow

```
Python (hello_world.py)
    ↓
Cython (hello_world.pyx) ── [Optimization: Type declarations]
    ↓
C Code (hello_world.c) ──── [Compilation: Cython compiler]
    ↓
WebAssembly (hello_world.wasm) ── [Compilation: Emscripten]
    ↓
TypeScript (index.ts) ────── [Integration: Type-safe wrapper]
```

### Performance Gains

- **Python**: 1x (baseline)
- **Cython**: 2-10x faster
- **C**: 10-100x faster
- **WebAssembly**: Near-native speed (similar to C)

### Use Cases

1. **Web Applications**: Run Python-like code in browsers
2. **Performance-Critical Code**: Optimize bottlenecks
3. **Cross-Platform**: Same code runs on server and client
4. **Legacy Code Migration**: Modernize Python apps

## 📖 Documentation

- **PIPELINE_GUIDE.md**: Complete step-by-step guide with explanations
- **Code Comments**: Each file is thoroughly documented
- **Type Definitions**: TypeScript types for full IDE support

## 🔧 Requirements

### Minimum (Python + Cython)
- Python 3.8+
- Cython
- GCC or Clang

### Full Pipeline
- All of the above, plus:
- Emscripten SDK
- Node.js 18+
- TypeScript 5+

## 💡 Example Output

Running the Python script creates a markdown file:

```markdown
# Hello World

Generated at: 2024-11-14 10:30:45

**Message:** Hello World!
```

Filename includes timestamp: `hello_world_20241114_103045.md`

## 🎓 Learning Path

1. **Start Here**: Run `./build_pipeline.sh` to see it all work
2. **Understand Each Step**: Read `PIPELINE_GUIDE.md`
3. **Modify & Experiment**: Try changing the Python code
4. **Performance Testing**: Compare execution times at each stage
5. **Real-World Application**: Apply to your own projects

## 🔗 Resources

- [Cython Documentation](https://cython.readthedocs.io/)
- [Emscripten Guide](https://emscripten.org/docs/)
- [WebAssembly Spec](https://webassembly.org/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## 🤝 Contributing

This is a learning project! Feel free to:
- Add more complex examples
- Optimize the pipeline
- Create benchmarks
- Add browser demos

## 📝 License

MIT License - Feel free to use this as a template for your projects!

## 📚 Citation

### Academic Citation

If you use this codebase in your research or project, please cite:

```bibtex
@software{python_cython_wasm_typescript_tutorial,
  title = {Python → Cython → WebAssembly → TypeScript: Complete Performance Optimization Pipeline},
  author = {Drift Johnson},
  year = {2025},
  url = {https://github.com/MushroomFleet/python-cython-wasm-typescript-Tutorial},
  version = {1.0.0}
}
```

## Donate

[![Ko-Fi](https://cdn.ko-fi.com/cdn/kofi3.png?v=3)](https://ko-fi.com/driftjohnson)

---

**Made with ❤️ to demonstrate the Python → WebAssembly pipeline**
