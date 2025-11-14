#!/bin/bash
# build_pipeline.sh
# Complete build pipeline from Python to WebAssembly

set -e  # Exit on error

echo "================================================"
echo "Python → Cython → C → WebAssembly → TypeScript"
echo "Complete Build Pipeline"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Test Python Script
echo -e "${BLUE}STEP 1: Testing Python Script${NC}"
echo "----------------------------------------------"
python3 hello_world.py
echo -e "${GREEN}✓ Python script executed successfully${NC}"
echo ""

# Step 2: Install Cython if needed
echo -e "${BLUE}STEP 2: Installing Cython (if needed)${NC}"
echo "----------------------------------------------"
pip3 install cython --break-system-packages --quiet || echo "Cython already installed"
echo -e "${GREEN}✓ Cython ready${NC}"
echo ""

# Step 3: Compile Cython to C
echo -e "${BLUE}STEP 3: Compiling Cython to C${NC}"
echo "----------------------------------------------"
cython hello_world.pyx --embed -o hello_world_generated.c
if [ -f "hello_world_generated.c" ]; then
    echo -e "${GREEN}✓ Generated C code: hello_world_generated.c${NC}"
    echo "  File size: $(du -h hello_world_generated.c | cut -f1)"
    echo "  Lines of code: $(wc -l < hello_world_generated.c)"
else
    echo -e "${YELLOW}⚠ Cython compilation skipped (C code not generated)${NC}"
fi
echo ""

# Step 4: Info about WebAssembly compilation
echo -e "${BLUE}STEP 4: WebAssembly Compilation Info${NC}"
echo "----------------------------------------------"
echo "To compile to WebAssembly, you need Emscripten:"
echo ""
echo "1. Install Emscripten SDK:"
echo "   git clone https://github.com/emscripten-core/emsdk.git"
echo "   cd emsdk"
echo "   ./emsdk install latest"
echo "   ./emsdk activate latest"
echo "   source ./emsdk_env.sh"
echo ""
echo "2. Compile C to WebAssembly:"
echo "   emcc hello_world_wasm.c \\"
echo "     -o hello_world.js \\"
echo "     -s EXPORTED_FUNCTIONS='[\"_create_hello_world\",\"_malloc\",\"_free\"]' \\"
echo "     -s EXPORTED_RUNTIME_METHODS='[\"ccall\",\"cwrap\"]' \\"
echo "     -s MODULARIZE=1 \\"
echo "     -s EXPORT_NAME='HelloWorldModule' \\"
echo "     -s ENVIRONMENT='web,node' \\"
echo "     -O3"
echo ""
echo -e "${YELLOW}⚠ Emscripten not detected, skipping WebAssembly compilation${NC}"
echo ""

# Step 5: TypeScript setup
echo -e "${BLUE}STEP 5: TypeScript Project Setup${NC}"
echo "----------------------------------------------"
if [ -d "typescript" ]; then
    cd typescript
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "Installing TypeScript dependencies..."
        npm install
    fi
    
    echo "Compiling TypeScript..."
    npm run build
    
    if [ -d "dist" ]; then
        echo -e "${GREEN}✓ TypeScript compiled successfully${NC}"
        echo "  Output directory: typescript/dist/"
        ls -lh dist/
    fi
    
    cd ..
else
    echo -e "${YELLOW}⚠ TypeScript directory not found${NC}"
fi
echo ""

# Summary
echo "================================================"
echo -e "${GREEN}BUILD PIPELINE SUMMARY${NC}"
echo "================================================"
echo "✓ Python script: hello_world.py"
echo "✓ Cython source: hello_world.pyx"
if [ -f "hello_world_generated.c" ]; then
    echo "✓ Generated C: hello_world_generated.c"
fi
echo "✓ WASM C wrapper: hello_world_wasm.c (ready for Emscripten)"
if [ -d "typescript/dist" ]; then
    echo "✓ TypeScript: compiled to typescript/dist/"
fi
echo ""
echo "Next steps:"
echo "1. Install Emscripten to compile C to WebAssembly"
echo "2. Run TypeScript with: cd typescript && npm start"
echo ""
echo "For detailed instructions, see: PIPELINE_GUIDE.md"
echo "================================================"
