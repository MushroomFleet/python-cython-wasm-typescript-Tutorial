# hello_world.pyx
# Cython version of our hello world script

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

# C-compatible wrapper for WebAssembly
def hello_world_wrapper():
    """
    Simple wrapper that returns the filename as a string.
    This makes it easier to call from WebAssembly.
    """
    return create_hello_world_file()
