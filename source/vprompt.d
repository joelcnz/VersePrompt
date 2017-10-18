#!rdmd
// above not work do this instead: 'rdmd vprompt.d' - not that either, just enter the name with the '.d' extenstion, but just for single files.
//#not work

/**
 * Title: Welcome to the Verse Prompt Bible Memory verse Program! <b>:-D</b>
 * Credits: digitalmars.com/d/2.0/index.html - Walter Bright - The D Programming Language
 */
module vprompt;

import std.file;

/*
 * To do: sitting tests eg. one chance per verse 2 points for letter perfect, 
 * point for word perfect, maybe point per letter
*/
private {
	import std.stdio: write, writeln, stdout;
	import std.string: split;
	import std.ascii: newline;
	import std.path;
	import command: Command;
	
	import jec;
	
	import base;
}

const LOG = "16 August 2017 - At Cecily's (ripping CD's) Look at word count status, auto select, grades system";
//const LOG = "14 August - turn on auto scroll";
//const LOG = "13 August 2017 - Emily's 3rd Birthday. Working on the Letter library, to trying to use less battery";
//const LOG = "11 August 2017 - Making status updates better (eg. history.txt)";
//const LOG = "9 August 2017 - merged library's to JecLib";
//const LOG = "3 August 2017 - DSFML version";
//const LOG = "22 July 2017 - DUB version on Timothy's other computer";
//const LOG = "8 Feburary 2015 - From Allegro 8 to 10";
//const LOG = "3 March 2013 - working on trying to get it going on Mac";
//const LOG = "24 April 2012 - inserted al_rest(#.#);";
//const LOG = "4 March 2012"; // update
//const LOG = "19 September(9) 2011"; // just changed the font
//const LOG = "15 September(9) 2011"; // Worked on it being more persentable - one guy said it wasn't in-te-you-it-tiv
//const LOG = "13 September(9) 2011"; // Suddenly every thing is up the shoot
//const LOG = "9 September(9) 2011"; // got it working with updated compiler
//const LOG = "2 September(9) 2011";
//const LOG = "1 September(9) 2011";
//const LOG = "25 August(8) 2011";
//const LOG = "24 August 2011";
//const LOG = "23 August 2011";
//const LOG = "22 August 2011"; // Convertion started
//const LOG = "26 July 2011"; // 11:19am
//const LOG = "25 July 2011 - Timothy's birthday"; // 6:04pm
//const LOG = "23 July 2011"; // 12:38pm
//const LOG = "12 May 2011"; // 12:15am!
//const LOG = "11 May 2011";
//const LOG = "18 February 2011"; // adding a Linux thing. With Ubuntu I have to copy to the Linux drive before being able to execute it.
//const LOG = "20 October, 2010";
//const LOG = "15 October, 2010";
//const LOG = "14 October, 2010";
//const LOG = "6 October, 2010";
//const LOG = "2 October, 2010";
//const LOG = "29 September, 2010";
//const LOG = "17 September, 2010";
//const LOG = "16 September, 2010";

/**
	The Main

	Creates and starts the command object
 */
int main(string[] args) {
	version(Windows) {
		writeln( "This is a Windows version of Verse Prompt." );
	}
	version(OSX) {
		writeln( "This is a Mac version of Verse Prompt." );
	}
	version(linux) {
		writeln( "This is a Linux version of Verse Prompt." );
	}

	if (setupAndStuff != 0) {
		import std.stdio: writeln;

		writeln("Error in setupAndStuff!");
	}

	return 0;
}

auto setupAndStuff() {
	immutable WELCOME = "Welcome to VersePrompt";
	g_window = new RenderWindow(VideoMode(800, 600), WELCOME);

    if (setup != 0) {
		gh("Aborting...");
		g_window.close;

		return 1;
	}

    immutable g_fontSize = 40;
    g_font = new Font;
    g_font.loadFromFile("DejaVuSans.ttf");
    if (! g_font) {
        import std.stdio: writeln;
        writeln("Font not load");
        return -1;
    }

    g_checkPoints = true;
    if (int retVal = jec.setup != 0) {
        import std.stdio: writefln;

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s", __FILE__, __FUNCTION__, __LINE__, retVal);
        return retVal;
    }

    //immutable size = 100, lower = 40;
    immutable size = g_fontSize, lower = g_fontSize / 2;
    jx = new InputJex(/* position */ Vector2f(0, g_window.getSize.y - size - lower),
                    /* font size */ size,
                    /* header */ "Word: ",
                    /* Type (oneLine, or history) */ InputType.history);
    jx.setColour(Color(255, 200, 0));
    jx.addToHistory(""d);
    jx.edge = false;

    g_mode = Mode.edit;
    g_terminal = true;

    jx.addToHistory(WELCOME);
    jx.showHistory = false;
    g_window.setFramerateLimit(60);

	g_letterBase = new LetterManager("lemgreen32.bmp", 8, 17, Square(0,0, g_window.getSize.x, g_window.getSize.y));

	with(g_letterBase) {
		updateFileNLetterBase("Version: " ~ LOG ~ newline ~ newline ~ 
					"Welcome to Verse prompt - Memory verse program" ~ newline);
		setLockAll(true);
	}

	( new Command() ).run();

	return 0;
}
