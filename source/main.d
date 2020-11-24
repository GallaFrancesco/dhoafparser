import parser.hoa;
import parser.loader;

import std.stdio;
import std.file;
import std.range;
import std.algorithm.searching;

int main(immutable string[] args)
{
    if(args.length < 2) {
        writeln("USAGE: dhoafparser [file.hoaf] [-v|--verbose]");
        writeln("    -v | --verbose    Dump parse tree");
        return 0;
    }

    auto pt = HOAFormat(readText(args[1]));

    if(!args.find("-v").empty || !args.find("--verbose").empty) {
        writeln("--- BEGIN PARSE TREE ---");
        writeln(pt);
        writeln("--- END PARSE TREE ---");
    }

    (pt.successful) ?
        writeln(args[1]~": is a valid Hanoi-Omega automaton.") :
        writeln(args[1]~": is NOT a valid Hanoi-Omega automaton.");

    // generate an immutable HOA struct
    immutable hoa = immutableHOA!hoaLoader;
    // hoa.nAP = 0; // should fail
    writeln(hoa.nStates);
    writeln(hoa.startSet);
    writeln(hoa.nAP);
    writeln(hoa.currentState);
    writeln(hoa.edges);


    return !pt.successful;
}
