# some google gemini script to add params to lua functions for better intellisense


import os
import re

# Get the directory where the script itself is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# Construct the path to "../src" relative to the script's location
SRC_FOLDER = os.path.join(SCRIPT_DIR, "../src")

# Matches a Lua function header using a pragmatic pattern:
# 'function' followed by one or more non-whitespace, non-parenthesis characters (the function name/path),
# followed by the parameters in group 2.
FUNC_LINE_PATTERN = re.compile(r'^\s*function\s+([^\s\(]+)\s*\((.*?)\)')

def process_file(file_path):
    # Process the file only if it exists and is a .lua file
    if not os.path.exists(file_path) or not file_path.endswith(".lua"):
        return

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except IOError as e:
        print(f"Error reading file {file_path}: {e}")
        return

    new_lines = []
    function_count = 0
    for i, line in enumerate(lines):
        match = FUNC_LINE_PATTERN.match(line)
        if match:
            # Group 2 contains the parameters
            params = match.group(2).strip() 
            
            # Check if the previous line exists and is not a comment line
            # Checking for lines[i-1].strip() ensures we ignore purely whitespace lines.
            if i == 0 or not lines[i-1].strip().startswith("--"):
                # Insert the new comment with parameters
                new_lines.append(f"-- ({params})\n")
                function_count += 1
            
        new_lines.append(line)

    if function_count > 0:
        try:
            with open(file_path, "w", encoding="utf-8") as f:
                f.writelines(new_lines)
            print(f"Processed {file_path}: Added {function_count} param comments.")
        except IOError as e:
            print(f"Error writing to file {file_path}: {e}")
    else:
        # Don't rewrite the file if no changes were made.
        print(f"Skipped {file_path}: No functions found or changes needed.")
        pass
    for i, line in enumerate(lines):
        match = FUNC_LINE_PATTERN.match(line)
        if match:
            params = match.group(2).strip() 
            print(f"Found function in {file_path}: Params: ({params})") # <--- ADD THIS
            # ... rest of the logic


def process_folder(folder):
    if not os.path.isdir(folder):
        print(f"Error: Source folder not found at '{folder}'")
        return

    print(f"Starting Lua file processing in: {folder}")
    for root, _, files in os.walk(folder):
        for file in files:
            if file.endswith(".lua"):
                process_file(os.path.join(root, file))

#---

if __name__ == "__main__":
    process_folder(SRC_FOLDER)
    print("---")
    print("All Lua files processed")