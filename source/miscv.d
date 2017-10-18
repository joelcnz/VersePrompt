/**
	Title: Misc - For extra bits that I want to use.
*/
module miscv;

/**
 *	CTFE function that generates trace code.
 *	Example:
	input:
	---
	int houseNumber=21;
	mixin( trace( "houseNumber" ) );
	---
	output:
	---
	houseNumber; 21
	---
	Instead of:
	---
	int houseNumber=21;
	writeln("houseNumber: ", houseNumber);
	---
	or:
	---
	int houseNumber=21;
	writefln("%s: %s", houseNumber.stringof, houseNumber);
	---
*/
string trace(in string varName) {
// eg mixin
	return `writeln("` ~ varName ~ `: ", ` ~ varName ~ `);`; 
}

