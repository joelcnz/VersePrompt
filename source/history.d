import std.file: append;

/// Add input line to the end of a text file
void appendLine(string line) {
	append("history.txt", line ~ "\n");
}
