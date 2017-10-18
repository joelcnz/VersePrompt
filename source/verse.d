//#needs more work
/**
	Verse module
	Date: 10-09-2010 - (time of module created)
*/
module verse;

private {
	import std.stdio: writeln;
	import std.string: replace, strip, removechars;
}

/**
	The verse class
*/
class Verse {
	private string m_verse;
	private uint m_id;
	
	/// get selection number
	uint getId() { return m_id; }
	
	/**
		Constructor - just sets in initial verse
	*/
	this(uint selNum, string verse) {
		m_id = selNum;
		setVerse(verse);
	}
	/// Set verse
	void setVerse(string newVerse) {
		m_verse=newVerse;
	}
	/// Returns verse as string
	string getVerse() {
		return m_verse;
	}
}
