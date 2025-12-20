import sys

# ANSI escape code for red text
RED = "\033[31m"
RESET = "\033[0m"

def read_file_lines(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return f.readlines()

def compare_files(file1, file2):
    lines1 = read_file_lines(file1)
    lines2 = read_file_lines(file2)

    total_chars = 0
    matching_chars = 0
    output_lines = []

    # Compare line by line
    for y in range(max(len(lines1), len(lines2))):
        line1 = lines1[y] if y < len(lines1) else ""
        line2 = lines2[y] if y < len(lines2) else ""
        max_len = max(len(line1), len(line2))
        new_line = ""

        # Compare character by character
        for x in range(max_len):
            char1 = line1[x] if x < len(line1) else " "
            char2 = line2[x] if x < len(line2) else " "
            total_chars += 1
            if char1 == char2:
                matching_chars += 1
                new_line += char1
            else:
                new_line += f"{RED}{char1}{RESET}"
        output_lines.append(new_line.rstrip("\n"))

    percentage = (matching_chars / total_chars) * 100 if total_chars > 0 else 100
    print(f"Matching characters: {matching_chars}/{total_chars} ({percentage:.2f}%)\n")
    
    # Print first file with mismatches in red
    for line in output_lines:
        print(line)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} file1.txt file2.txt")
        sys.exit(1)

    compare_files(sys.argv[1], sys.argv[2])
