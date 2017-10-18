//#appendLine
//#think I'll use strings in a struct instead of enum
/**
	Title: File Control
	Add new verses, clear verses, load seconds, save verses
*/
module filecontrol;

private {
	import std.stdio: write, writeln, writefln, readln;
	import std.string: strip, stripRight, toLower, lastIndexOf, isNumeric, inPattern, format;
	import std.ascii: digits;
	import std.file: DirEntry, dirEntries, SpanMode, exists;
	import std.conv: to;
	import std.path: dirSeparator;
	import std.exception;
	
	import dsfml.graphics;
	import dsfml.audio;

	import section: Section;
	import miscv: trace;
	import history: appendLine;
	
	import base;
}

string newline = "\n";

/// Add new verses, clear section, load sections, save sections
struct FileControl {
private:
	Section _section, _initSection;
	enum Filecontrol : string {PRINT_HELP = "h", ADD_VERSE = "a", REMOVE_LAST_VERSE = "r", CLEAR_SECTION = "c",
		LOAD_SECTION = "l", LOAD_APPEND = "la", SAVE_SECTION = "s",
		GO_BACK_TO_COMMAND = "b"} //#think I'll use strings in a struct instead of enum
	string indent;
	enum LoadType {fromScratch, append}
public:
	/// Constructor: keep a copy of last section, start a new empty section
	this(Section section) {
		_section = section;
		indent = "    "; // 4 spaces, like a tab
	}

	/// Title: Main loop
	/// Handles input commands
	Section run(out bool doExit) {
		doExit = false;
		string userInput; // stores input commands
		auto enterPressed = false;
		auto header = true;
		auto done = false; // continue loop condistion(sp)
		do {
			// shows this every time your prompted
			if (header) {
				header = false;
				updateFileNLetterBase(indent ~ "File control menu (enter 'h' for help)");
				g_letterBase.setText(g_letterBase.getText() ~ indent);
				g_letterBase.setLockAll(true);
				//g_letterBase.letters[g_letterBase.count - 1].lock = true;
			}
			int prefix = g_letterBase.count();
			break0: while(! enterPressed) {
				if (! g_window.isOpen())
					done = true;

				Event event;

				while(g_window.pollEvent(event)) {
					if(event.type == event.EventType.Closed) {
						done = doExit = true;
						break break0;
					}
				}

				g_window.clear;
				
				g_letterBase.draw();

				with( g_letterBase ) {
					doInput(/* ref: */ enterPressed);
					update(); //#not much
				}

				g_window.display;				
			}

			enterPressed = false;
			g_letterBase.setLockAll(true);
			userInput = g_letterBase.getText()[prefix .. $].stripRight;
			prefix = g_letterBase.count();
			debug
				mixin( traceList( "prefix", "g_letterBase.count", "userInput" ) );
//			if ( userInput != "b" )
//				userInput = g_letterBase.getText()[ prefix .. $ ].stripRight;
			debug 
				mixin( trace( "userInput" ) );
			//#appendLine
			//appendLine( userInput );
			if (userInput.length == 1 || userInput == Filecontrol.LOAD_APPEND ) { // if the input is just one character
				switch (userInput) {
					// Display help
					case Filecontrol.PRINT_HELP:
						with (Filecontrol)
							updateFileNLetterBase(
								indent ~ "File Control Help:" ~ newline ~
								indent ~ GO_BACK_TO_COMMAND ~ " - Quit back" ~ newline ~
								indent ~ LOAD_SECTION ~ " - Load section" ~ newline);
					break;
					// Load a section
					case Filecontrol.LOAD_SECTION:
						loadSection(LoadType.fromScratch);
					break;
					case Filecontrol.LOAD_APPEND:
						loadSection(LoadType.append);
					break;
					// Save current section
					case Filecontrol.SAVE_SECTION:
						//saveSection;
					break;
					// quit File control
					case Filecontrol.GO_BACK_TO_COMMAND, "q":
						done = true;
						if (userInput == "q") {
							doExit = true;
						}
						if (_section.isClear) {
							updateFileNLetterBase(indent ~ "Note: Section is empty.");
						}
					break;
					// For unaccounted for (except for this)
					default:
					break;
				}
			} // if
			header = true;
		} while (! done);

		return _section;
	}
	
	/// Save section
	void saveSection() {
		throw new Exception( "save section not implemented" ); // was FileException
		version(none) {		
			g_letterBase.addTextln(indent ~ "Enter file name to save section to:");
			string filename = "sections" ~ dirSeparator ~ strip( readln() ) ~ ".txt"; // prepare relative file name
			_section.saveFile(filename);
		}
	}
	
	/// Load section from a list (sections/*.txt folder of txt files)
	void loadSection(LoadType loadType) {
		g_letterBase.addTextln( indent ~ "Load" ~ 
			(loadType == LoadType.append ? " append " : " ") ~
			"section ('-1' to cancel):" ); // display what to do
		const root = `sections`; // set local root - forward slash works with Windows and Linux
		int index = 0; // for verses id's for the user to select which file to load
		string[] filenames; // Collect all text file names
		string list = indent;
		// Iterate a directory and get detailed info about it
		foreach (string name; dirEntries(root, SpanMode.shallow)) {
			import std.algorithm: endsWith;
			import std.array: replicate;
			import std.conv: text;
			if (name.endsWith(".txt")) { // is it a txt file name?
				filenames ~= name; // add filename
				auto lname = name[lastIndexOf(name, dirSeparator) + 1 .. $ - 4];
				// display info
				auto doNewLine = ! ((index + 1) % 4);
				auto gap = " ".replicate(18 - lname.length);
				list ~= format("%s%s", text((index < 10 ? " " : ""), index++, ") ", lname, gap),
											 (doNewLine ? newline ~ indent : ""));
			}
		 }
		list ~= newline;
		g_letterBase.setText( g_letterBase.getText() ~ list ~ indent ~ "Enter a number:" ~ newline ~ indent);
		string input;
		g_letterBase.letters[ g_letterBase.count - 1 ].lock = true;
		int prefix = g_letterBase.count();
		auto enterPressed = false;
		auto done = false;
		while(! enterPressed) {
			Event event;

			while(g_window.pollEvent(event)) {
				if(event.type == event.EventType.Closed) {
					enterPressed = done = true;
				}
			}

			if (! g_window.isOpen())
				enterPressed = done = true;

			 if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) ||
				 Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
				Keyboard.isKeyPressed(Keyboard.Key.Q))
				done = true;

			g_window.clear;
			
			g_letterBase.draw();

			with( g_letterBase ) {
				doInput(/* ref: */ enterPressed);
				update(); //#not much
			}

			g_window.display;				
		}
		if (done)
			return;
		input = g_letterBase.getText()[ prefix .. $ ].stripRight;

		import std.algorithm: filter, canFind;
		import std.conv: to;
		string input2 = input.filter!(a => (digits ~ '-').canFind(a)).to!string;
		enterPressed = false;
		input.length = 0;
		g_letterBase.setLockAll(true);
		prefix = g_letterBase.count();
		if (isNumeric(input2)) {
			int fileNumber = input2.to!int; // get user input and make it a number

			if (fileNumber < 0  || fileNumber >= filenames.length) { // is input is a valid number
				if ( fileNumber == -1 ) {
					g_letterBase.addTextln(indent ~ "Loading canceled." );
				}
				else {
					g_letterBase.addTextln(indent ~ "Number not listed, enter 'l' to try again."); // display error message
				}
			}
			else {
				if (loadType == LoadType.fromScratch) {
					_section.clearSection;
				}
				_section.getSectionFromFile(filenames[fileNumber]); // ok, load in section
				updateFileNLetterBase(indent, filenames[fileNumber], " Section loaded");
			}
		} else {
			g_letterBase.addTextln(indent ~ "Invalid input, enter 'l' to try again."); // display error message
		}
	}
}
