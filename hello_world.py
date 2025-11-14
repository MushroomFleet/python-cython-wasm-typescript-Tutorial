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
