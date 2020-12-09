import dhoafparser.loader;

import std.stdio;
import std.file;
import std.range;
import std.algorithm.searching;
import std.conv : to;
import std.getopt;

immutable string helpInfo = `dhoafparser - version 0.1 - Parse and validate a HOA automaton.
Usage: dhoafparser [-f hoaFile | -s hoaString ] [options...]
---
Exit codes:
    0: VALID automaton
    1: INVALID automaton (HOA input could not be parsed successfully)
    2: invocation error / help wanted
---`;

struct CLIOpts {
    bool verbose;
    bool dump;
    string hoaFile;
    string hoaString;
    bool wrong = false;
}

CLIOpts handleCLI(string[] args) @safe
{
    CLIOpts opts;
    GetoptResult helpInformation;

    try {
        helpInformation = getopt(
                                 args,
                                 "hoaFile|f", "Filename of a HOA file", &opts.hoaFile,
                                 "hoaString|s", "String representation of a HOA", &opts.hoaString,
                                 "verbose|v", "Dump parse tree", &opts.verbose,
                                 "dump|d", "(pretty) Dump generated HOA struct", &opts.dump);

        if (helpInformation.helpWanted ||
            (!opts.hoaFile.empty && !opts.hoaString.empty) ||
             (opts.hoaFile.empty && opts.hoaString.empty))
            {
                () @trusted {
                    defaultGetoptPrinter(helpInfo, helpInformation.options);
                } ();
                opts.wrong = true;
            }

    } catch (Exception e) {
        writeln(helpInfo);
        writeln(e.msg);
        writeln("try: dhoafparser --help");
        opts.wrong = true;
    }
    return opts;
}

void dumpHOA(immutable HOA hoa) @safe
{
    writeln("--- DUMP ---");
    if(!hoa.valid) {
        writeln("Cannot dump invalid automaton.");
    } else {
        // hoa.nAP = 0; // should fail at compile time
        writeln("N. of states: "~to!string(hoa.nStates));
        writeln("N. of atomic propositions: "~to!string(hoa.nAP));
        writeln("Initial state list: "~to!string(hoa.startSet));
        writeln("Acceptance type: "~to!string(hoa.acceptance));
        if(hoa.acceptance == Acceptance.TGBA)
            writeln("Edge list (FORMAT from -> to [label] {edge accepting sets})");
        else 
            writeln("Edge list (FORMAT from {state accepting sets} -> to [label])");
        foreach(edge; hoa.edges) {
            writeln(edge.dump());
        }
    }
    writeln("--- END ---");

}

int main(string[] args) @safe
{
    CLIOpts opts = handleCLI(args);
    if(opts.wrong) return 2;

    string hoaBuf;
    (opts.hoaFile.empty) ?
        (hoaBuf = opts.hoaString) :
        (hoaBuf = readText(opts.hoaFile));

    immutable hoa = loadHOA(hoaBuf, opts.verbose);
    (hoa.valid) ?
        writeln("This is a valid Hanoi-Omega automaton.") :
        writeln("This is NOT a valid Hanoi-Omega automaton.");

    if(opts.dump) dumpHOA(hoa);    

    return !hoa.valid;
}
