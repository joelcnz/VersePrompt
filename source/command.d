//#name not working!
//#not sure about this if
//#enter pressed
//#dont think SET_VERSE will work
//#probably pointless
/**
 * 	Command Centre (report to the commanders office) - Handle inputs module
*/
module command;

private {
	import std.stdio: writeln, writefln, readln;
	debug
		import std.stdio: writef;
	import std.string: isNumeric, format, strip, stripRight;
	import std.ascii: newline;
	import std.conv: to;

	import section: Section;
	import filecontrol: FileControl;
	import history: appendLine;
	
	//import jexta.all;
	//import jext.base;
	import jec;
	
	import base;
}

enum : bool {YES = true, NO = false}

/**
	Verses manager class
*/
class Command {
private:
	Section _section; // Contains verse(s) (data), and a compare method etc.
	bool doExit;
public:
	/**
		Init verse and enums to be more readable
	*/
	enum Command : string {GO_TO_NEXT_VERSE = "n", SET_VERSE_BY_REFERENCE = "s", SET_VERSE_BY_INDEX = "svi", HELP = "h", VERSE = "v",
		CLEAR = "c", LIST = "l", FILE_CONTROL = "f", DO_TEST = "t", QUIT = "q"}
	
	this() {
		// Start with no verses in section
		Section.setup;
		_section = new Section([]);
		_section.clearSection;
		debug {
			destroy(_section); //#probably pointless
			_section = new Section(["a a a", "s s s"]);
		}
	}
	
	/**
	 * Main method, has the verse memory commands.
	 */
	void run() {
		with( g_letterBase )
			setTextType( TextType.line );
		scope(exit)
			g_window.close();
		bool isVerse; // is it a verse (or a command)
		string userInput;
		auto enterPressed = false; //#enter pressed
		auto header = false;
		int prefix;
		//prefix = g_letterBase.count();
		auto done = NO;
		auto enterYourName = true;
		enum State {name, normal}
		auto state = State.normal; // name; //#name not working!
		updateFileNLetterBase("Enter memory verse, (Enter 'h' for help):");
		g_letterBase.setLockAll(true);
		prefix = g_letterBase.count();
		do {
			if (! g_window.isOpen())
				done = YES;

			Event event;

			while(g_window.pollEvent(event)) {
				if(event.type == event.EventType.Closed) {
					done = YES;
				}
			}

			if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
				Keyboard.isKeyPressed(Keyboard.Key.Q))
				done = YES;

			switch0: final switch(state) with(State) {
				case name:
				/+
					if (firstRun) {
						firstRun = false;
						g_letterBase.addTextln("Enter your name, (Enter 'q' to quit):");
						g_letterBase.setLockAll(true);
						prefix = g_letterBase.count();
					}
					if (enterPressed) {
						enterPressed = false;
						if (userInput == "q") {
							done = true;
							break switch0;
						}
						updateFileNLetterBase("User Name: ", userInput);
						g_letterBase.setLockAll(true);
						prefix = g_letterBase.count();
						state = State.normal;
					}
					+/
				break;
				case normal:
					// print for prompt, text depending on whether the section has any verses or not
					if (enterPressed || header) {
						header = false;
						enterPressed = false;
						updateFileNLetterBase("Enter memory verse, (Enter 'h' for help):");
						g_letterBase.setLockAll(true);
						prefix = g_letterBase.count();
					}
					userInput = update(prefix, enterPressed);
//					if (doExit)
//						userInput = "q";
					if (userInput.length > 0)
					{
						isVerse = YES; // is it a verse (or a command)
						// Commands are all one character and index 0
						if (userInput.length == 1)
						{
							// check to see if verse or command
							with (Command)
								//#dont think SET_VERSE will work
								foreach (command; [HELP, CLEAR, LIST, VERSE, FILE_CONTROL, GO_TO_NEXT_VERSE,
												DO_TEST, QUIT])
									if (userInput == command)
										isVerse = NO; // do not treat as verse

							// If command not used, the user input is treated as thing typed from memory
							// Switch on command
							switch (userInput) {
								// Display help
								case  Command.HELP:
									with (Command)
										g_letterBase.addTextln("Help:" ~ newline ~
											QUIT ~ " - Quit" ~ newline ~
											FILE_CONTROL ~ " - File control" ~ newline ~
											HELP ~ " - This help" ~ newline ~
											VERSE ~ " - View current memory verse" ~ newline ~
											CLEAR ~ " - Clear screen (hide memory verse)" ~ newline ~
											LIST ~ " - Show all verses in current section" ~ newline ~ ""
										//	DO_TEST ~ " - Sit test Points: 2) for 'letter perfect'. 1) for 'word perfect' 0) otherwise" ~ newline
										);
								break;
								// Do test
								case "t":
								/+
									if ( _section.isClear == false )
									{
										clearScreen.clearScreen;
										g_letterBase.addTextln( "Your test is now!" );
										_section.doTest;
									}
									else
									{
										g_letterBase.addTextln( "No verses for you to be tested with." );
									}
								+/
								break;
								// List verses to choose from
								case Command.LIST:
									if (_section.isClear == false)
									{
										updateFileNLetterBase("Current section:");
										// loop through all verses (whole section)
										_section.listAllVerses;
									}
								break;
								// Clear screen (hide verses)
								case Command.CLEAR:
									clearScreen(/* ref */ prefix);
									//enterPressed = false;
									//header = true;
								break;
								// display current verse
								case Command.VERSE:
									if (_section.isClear == false)
										updateFileNLetterBase(newline ~ _section.getCurrentVerse ~ newline);
									else
										updateFileNLetterBase("There /is/ no current verse.");
								break;
								// Go to file control: add, load and save
								case Command.FILE_CONTROL:
									doExit = doFileCommand();
									enterPressed = false;
									header = true;
								break;
								// quit program
								case Command.QUIT:
									done = true;
								break;
								default:
								break;
							} // switch userInput[0]
						} // if length == 1
					}
					if (isVerse == YES && enterPressed) {
						if (_section.isClear == YES)
						{
							g_letterBase.addTextln("Nothing to memorise.");
						}
						else { // if secion isn't empty
							g_letterBase.copyInputText();
							// compares with sections current verse
							_section.getVerseFromInput(userInput); // set verse from input
							updateFileNLetterBase(_section.compare(userInput)); // do compare of user verse and current verse
						}
					}
				break;
			} // switch
		} while (! done); // Exit to OS
	}

	/// clear the screen
	typeof(this) clearScreen(ref int prefix)
	{
		//g_letterBase.setText("Enter memory verse, (Enter 'h' for help):\n");
		//prefix = g_letterBase.count();
		g_letterBase.setText("");

		return this;
	}
	
	/// Go to file control menu, it can change the current section
	bool doFileCommand() {
		auto fileControl = FileControl(_section); // use current section
		_section = fileControl.run(doExit);
		return doExit;
	}
}

/** Clear and draw, get input */
auto update(ref int prefix, ref bool enterPressed) {
	g_window.clear;
	
	g_letterBase.draw();

	with(g_letterBase) {
		doInput(/* ref: */ enterPressed);
		update(); //#not much
	}

	g_window.display;
	
	string userInput = "";
	if (enterPressed) {
		userInput = g_letterBase.getText()[prefix .. $ ].stripRight;
		upDateStatus(userInput);
		debug
			mixin( traceList( "prefix", "g_letterBase.count", "userInput" ) );
	}

	return userInput;
}
