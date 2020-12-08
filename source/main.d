import dhoafparser.loader;

import std.stdio;
import std.file;
import std.range;
import std.algorithm.searching;
import std.conv : to;
import std.getopt;

int main(string[] args)
{
    bool verbose;
    string hoaFile;
    string hoaString;

    auto helpInformation = getopt(
                    args,
                    "hoaFile|f", "Filename of a HOA file", &hoaFile,
                    "hoaString|s", "String representation of a HOA", &hoaString,
                    "verbose|v", "Dump parse tree", &verbose);

    if (helpInformation.helpWanted ||
        (!hoaFile.empty && !hoaString.empty))
    {
        defaultGetoptPrinter("Parse and validate a HOA automaton.",
                            helpInformation.options);
        return 0;
    }

    string hoaBuf;
    (hoaFile.empty) ?
        (hoaBuf = hoaString) :
        (hoaBuf = readText(hoaFile));

    immutable hoa = loadHOA(hoaBuf, verbose);
    (hoa.valid) ?
        writeln("This is a valid Hanoi-Omega automaton.") :
        writeln("This is NOT a valid Hanoi-Omega automaton.");

    // hoa.nAP = 0; // should fail at compile time
    if(verbose) {
        writeln("--- DUMP ---");
        writeln("N. of states: "~to!string(hoa.nStates));
        writeln("N. of atomic propositions: "~to!string(hoa.nAP));
        writeln("Initial state list: "~to!string(hoa.startSet));
        writeln("Edge list (FORMAT from -> to [label] {accepting sets})");
        foreach(edge; hoa.edges) edge.dump();
        writeln("--- END ---");
    }

    return !hoa.valid;
}
