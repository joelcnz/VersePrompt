//org: see - http://3d.benjamin-thaut.de/?p=15
//Compile: dmd example stacktrace dbghelp -run
import stacktrace;

void blup(){
	assert(0,"fail");
}

void main( string[] args )
{
    blup();
} 
