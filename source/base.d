//#try this one
module base;

import std.stdio;
import std.string;
import std.datetime.stopwatch;
import std.conv;
import std.range;

public import jec;

//version = FramePerSecond;

LetterManager g_letterBase;

void updateFileNLetterBase(T...)(T args) {
	import std.typecons: tuple;
	import std.conv: text;

	//g_letterBase.addTextln(args); //#try this one
	//g_letterBase.addTextln(text(tuple(args).expand));
	g_letterBase.addTextln(text(args));
	upDateStatus(args);
}

uint g_frameCounter = uint.max, g_fps = 0, g_sec = 0;
StopWatch g_sw, g_sws;
uint g_frameSkipCounter = 0, g_frameSkipNumber = 1; //10;
immutable g_fontDir = `fonts`;

static this() {
	g_sw.start,
	g_sws.start;
}
