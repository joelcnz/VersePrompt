//#this shouldn't happen
//#I think this mite be obsolete
//#stuffed in
//# not sure about this
/**
	Section - Verse manager module

	Authors: Joel Ezra Christensen, joelcnz@gmail.com

	Date: September 11, 2010
*/
module section;

//debug = ExtraDebug;

private {
	import std.stdio; //: write, writeln, writefln, strip, readln, File, FileException;
	import std.file: FileException;
	import std.string: isNumeric, toLower, replace, inPattern, stripRight,
		indexOf, format, split, strip;
	import std.ascii: newline, digits;
	import std.conv: to;
	import std.algorithm: countUntil; 
	import command: Command;
	import verse: Verse;
	import miscv: trace;
	
	import base;
}

/**
	Verses manager class
*/
class Section {
private:
	Verse _currentVerse; // Currently selected verse
	Verse[] _allVerses; // Whole section, made up of verses
public:
	/*
		Init verse and enums to be more readable
	*/
	/// For more readablitly(sp)
	enum: bool {YES = true, NO = false};

	static string[string] grade;

	static void setup() {
		grade = ["fail":"Not so good", "good":"Word Perfect!", "great":"Letter Perfect!"];
	}

	/// Work out verse from the first few letter from the user
	void getVerseFromInput(string userInput) {
		if (userInput.length < 3)
			return;
		foreach (i, sverse; _allVerses) {
			import std.algorithm: map;
			import std.array: array;
			import std.ascii: toLower;
			if (userInput.length > 2 && sverse.getVerse[0 .. 3].map!toLower.array == userInput[0 .. 3].map!toLower.array) {
				_currentVerse = _allVerses[i];
				with(g_letterBase) {
					copiedText = userInput;
					auto verse = sverse.getVerse;
					import std.algorithm: canFind, countUntil;
					import std.ascii: digits;

					auto endOfPiece = verse.countUntil!(a => ! digits.canFind(a));
					if (i == 0) {
						endOfPiece = 2 + verse[2 .. $].indexOf(' ');
					}
					if (endOfPiece == -1) //#this shouldn't happen
						endOfPiece = 0;
					updateFileNLetterBase("Verse ", verse[0 .. endOfPiece], ", auto selected.");
				}
				
				return;
			}
		}
	}
	
	/// Get ID number of current verse
	uint getVerseID() {
		return _currentVerse.getId;
	}
	
	/// Check to see if any verses in section
	bool isClear() { return _allVerses.length == 0; }
	
	/**
		Constuctor: Takes the section in string format and breaks it up into more managable piecs.
	*/
	this(string[] allVerses) { //# not sure about this
		addVersesFromStrings(allVerses);
	}
	
	/// Clear section (eg. for adding new verses)
	void clearSection() {
		_allVerses.length = 0;
		_currentVerse = null;
	}
	
	/**
		Takes verse strings and adds them to the Verse array<br>
		eg. When you load a section
	*/
	void addVersesFromStrings(string[] allVerses) {
		// Add all verses from strings
		foreach (i, verse; allVerses)
			addVerse(verse);
		// Set current verse variable to first verse
		if (_allVerses.length != 0)
			_currentVerse = _allVerses[0];
		else {
			updateFileNLetterBase("Note: no verses in section.");
			debug
				writeln("Note: no verses in section.");
		}
		debug (ListVersesWhenAdded)
			listAllVerses; // display verses to check them
	}
	
	/// Remove last verse, if there's one
	void removeLastVerse() {
		if ( _allVerses.length > 0 )
		{
			_allVerses = _allVerses[0 .. $ - 1];
		}
		else
		{
			writeln("There is no last verse.");
		}
	}
	
	/// Get current verses string
	@property string getCurrentVerse() {
		if (_currentVerse is null)
			return "";
		return _currentVerse.getVerse;
	}
	
	/// Get all verses (not strings)
	Verse[] getAllVerses() {
		return _allVerses;
	}
	
	/// Add verse
	void addVerse(string verse) {
		_allVerses ~= new Verse(cast(int)_allVerses.length, verse);
		_currentVerse = _allVerses[0];
	}
	
	/// List all verses
	void listAllVerses() {
		if (getAllVerses.length == 0) { // is there even any in there?
			updateFileNLetterBase("No verses to speak of");
		} else {
			foreach( i, currentVerse; getAllVerses ) {
				updateFileNLetterBase(format("%s", currentVerse.getVerse));
			}
		}
	}
	
	/// Do test
	void doTest()
	{
		version(none) {
		auto holdVerse = _currentVerse;
		scope (exit)
			_currentVerse = holdVerse;
		int total = 0;
		real max = _allVerses.length * 2;
		foreach ( verse; _allVerses ) {
			_currentVerse = verse;
			Grade grade = compare( strip( readln() ) );
			total += grade == Grade.LETTER_PERFECT ? 2 : grade == Grade.WORD_PERFECT ? 1 : 0;
			debug
				g_letterBase.addTextln(
					grade == Grade.LETTER_PERFECT ? "perfect!"
					: grade == Grade.WORD_PERFECT ? "good!" : "fail!");
		}
		if ( total > 0 )
		{
			debug 
				writefln("%s%% - total = %s, max = %s", cast(int)(total / max * 100), total, max );
			else
				g_letterBase.addTextln( format( "%s%%", cast(int)(total / max * 100) ) );
		}
		else
		{
			g_letterBase.addTextln( "0%, need more practice, me thinks" );
		}
		} // version
	}

	/// Get how right it is returning percentage of how right it is
	/// return: percentage
	/// debug: not correct
	//#needs more work
	real getComparePercentage( string user ) {
		if ( user.length == 0 || getCurrentVerse.length == 0)
			return 0f;
		auto userOrginal = user;

		int c = 0;
		auto verse = getCurrentVerse.dup;
		for( int i = 0; i < verse.length; ++i ) {
			for( int i2 = 0; i2 < user.length && i2 >= 0 && i >= 0; ++i2 ) {
				debug( ExtraDebug ) {
					mixin( trace( "i" ) );
					mixin( trace( "i2" ) );
				}
				char u, v;
				u = user[ i2 ];
				v = verse[ i ];
				
				if ( u == v ) {
					++c;
					debug( ExtraDebug )
						writeln( "Count: ", c, "Current: ", u );
					user = user[ 0 .. i2 ] ~ user[ i2 + 1 .. $ ];
					verse = verse[ 0 .. i ] ~ verse[ i + 1 .. $ ];
					debug( ExtraDebug ) {
						writeln( "user: >", user, '<' );
						writeln( "verse: >", verse, '<' );
					}
					--i2;
					--i;
				}
			}
		}
		debug
			writeln( "user: ", user.length, " verse: ", getCurrentVerse.length, " count: ", c);
		auto percentOfAmountExisting = ( cast(real)c / getCurrentVerse.length ) * 100;
		double percentOfAmountNotExisting = 0f;
		if ( userOrginal.length > 0 && getCurrentVerse.length > 0 &&
			userOrginal.length > getCurrentVerse.length )
			percentOfAmountNotExisting = 100 -  ( cast(double)getCurrentVerse.length / userOrginal.length ) * 100;
		debug {
			mixin( trace( "percentOfAmountExisting" ) );
			mixin( trace( "percentOfAmountNotExisting" ) );
		}
		
		updateFileNLetterBase(format("Percent extra: %.2f%%", percentOfAmountNotExisting));

		return percentOfAmountExisting;
	}
	
	/// Check to see if the string can be converted into a number
	bool checkIsNumber(in string str)	{
		foreach(c; str) {
			import std.algorithm: canFind;
			if (! digits.canFind(c)) //inPattern( c, digits ) )
				return false;
		}
		return true;
	}

	/**
`		Title: Check users verse against the <i>actual</i> verse
		Returns: the resulting grade
	*/
	auto compare(string userVerse) {
		//#stuffed in
		import std.math: round;
		updateFileNLetterBase(format("Character percent %.2f%%", getComparePercentage(userVerse).round));
		
		string textAgainstVerse = _currentVerse.getVerse; // copy verse so as not to mess with it
		// Return perfect grade if verse is identical to current memory verse
		if (userVerse == textAgainstVerse)
			// if verses are the same right down to the punchuation(sp) (but can get this result with spaces at the start and/or finish though
			return grade["great"];

		// Simplify verses by appling functions to them
		// Note: white spaces and the start and end are stiped off all ready
		void simplify(ref string txt) {
			import std.ascii: toLower, lowercase, digits;
			import std.string: replace;
			import std.algorithm: map, filter, canFind;
			import std.range: array;
			import std.conv: to;

			txt = txt
				.map!toLower
				.filter!(a => (lowercase ~ digits ~ ' ').canFind(a))
				.array
				.replace("  ", " ")
				.to!string;
		}

		simplify(userVerse);
		simplify(textAgainstVerse);
		debug
			mixin(traceList("userVerse", "textAgainstVerse"));

		int totalWords = 0, correctWords = 0;
		totalWords = cast(int)textAgainstVerse.split.length;
		auto textAgainstVerseTmp = textAgainstVerse.split;
		foreach( word; userVerse.split ) {
			int pos;
			auto found = (pos = cast(int)countUntil(textAgainstVerseTmp, word)) > -1;
			//debug
			//	writeln( "found: ", pos );
			if (found) {
				//debug
				//	writeln("Pos: ", pos, ' ', textAgainstVerseTmp.length);
				if (textAgainstVerseTmp.length > 1)
					textAgainstVerseTmp = textAgainstVerseTmp[0 .. pos] ~
						textAgainstVerseTmp[pos + 1 .. $];
				//debug
				//	writeln("By words: <", textAgainstVerseTmp, '>');
				++correctWords;
			}
		}
		
		updateFileNLetterBase(format("Word: %d/%d correct. Extra: %d",
				correctWords, totalWords,
				(userVerse.split.length > totalWords ? userVerse.split.length - totalWords : 0)));
		
		if (userVerse == textAgainstVerse)
			return grade["good"]; // the second best comparason(sp)

		return grade["fail"]; // if could not successfully compare verses
	}

	/**
		Goes through a copy of the orgText string and for every charater incounted in the chars string a space is inserted
		params:
			orgText = string that is copied to another which is then processed
			chars = is the list of characters that replaced with a space when found in the string being processed
		Example:
		---
assert(wipeOutChars(".J...J.J.", ",.") == " J   J J ");
		---
		Returns: the processed string
	*/
	string wipeOutChars(string orgText, in string chars) {
		return "";
		/+
		import std.ascii;
		import std.string;
		import std.algorithm;
		import std.range;
		import std.conv;

		return orgText.map!(a => a.toLower).filter!(a => lowercase.canFind(a)).array.replace("  "d, " "d).to!string;
		auto text = orgText.dup; // to char[]
		foreach (ref c; text)
			if (inPattern(c, chars) || c == '-')
				c = ' ';
		return text.idup; // back to string
		+/
	}
	
	/**
		Recursive method reduces mulitpul(sp) contigenonous(sp) spaces to one<br>
		Reduces all places with extra ajasint(sp) spaces to a single space<br>
		<br>
		<b>Example:</b><br>
		assert(removeSpaces("a &nbsp;&nbsp;&nbsp;b c") == "a b c");
		Returns: the processed string
	*/
	string removeSpaces(string text) {
		string lastString=text.idup;
		text = replace(text, "  ", " ");
		if (text != lastString) // if string new different than it was at the start of the method
			return removeSpaces(text); // recursion
		return strip(text);
	}
	
	/// Save section to file
	void saveFile(string filename) {
		File f;
		scope (exit) { // execute at method exit
			f.close;
		}
		// test incase of error
		try {
			f = File(filename, "w"); // open file for writing
			foreach (i, verse; _allVerses) // write each verse as a string
				// I think "\n" gets converted to "\r\n" so using "\r\n" you get "\r\r\n"
				f.write(verse.getVerse,i != cast(int)_allVerses.length - 1 ? "\n" : "");
		} catch (FileException e) {
			updateFileNLetterBase("Saving section file error!");
		}
	}

	/// Load selection using filename
	void getSectionFromFile(string filename) {
		File f;
		string[] verses;
		scope (success) {
			addVersesFromStrings(verses);
			// Set current verse variable to first verse
			if (_allVerses.length > 0)
				_currentVerse = _allVerses[0]; //#I think this mite be obsolete
			else
				updateFileNLetterBase("No verses loaded. Empty file?");
		}
		try {
			// load text file
			f = File(filename, "r");
			if (! f.isOpen)
				throw new Exception("File not open"); // f.close; still gets called
			char[] buf;
			debug {
				mixin(trace("verses.length")); // display for example 'verses.length: 0', don't have to type variable in twice
				write("["); // to show the very start of the text file
			}
			
			while(f.readln(buf)) { // read in text file line by line
				verses ~= stripRight(buf.idup); // add line as verse
				debug
					write(buf); // show all the text file contentce(sp)
			}
			debug
				writeln("]"); // show where the file ends
		} catch (Exception e) { // catch things going wrong
			updateFileNLetterBase("File error: ", e.msg); // display error message, and that there is one
		}
		finally { // call this what ever happens (eg. file failure)
			f.close;
		}
	}
	
	/// Clear all the memory verses in section for using append verse
	void clearVerses() {
		_currentVerse = null;
		_allVerses.length = 0;
	}
}
