# dhoafparser

A parser for the Hanoi Omega-Automata format. `dhoafparser` grammar is
written as a PEG, thanks to the
[pegged](https://github.com/PhilippeSigaud/Pegged) library.

The parser can be compiled into a command line tool which
reads a file containing the HOA representation of an automaton. The
program validates the file and optionally prints the whole parse tree.

Alternatively, the parser can be used as a library by including the `source/dhoaparser/`
directory.

## Design

Build a parser for the Hanoi Omega-Automata format which returns a
data structure representing a given HOA. `struct HOA` must:
- be `immutable` once constructed;
- allow further encoding by providing range-like access to the body of
  the automaton, represented as a list of edges.

## Building and Usage

Requires a D compiler and Dub. The easiest way to get them (on Linux)
is to use the [install.sh script](https://dlang.org/install.html)
provided by the D foundation.

```
git clone https://github.com/gallafrancesco/dhoafparser.git
cd dhoafparser
dub build
```
Test the command line tool on the provided example automaton (optionally, use -v to print the whole parse tree).

```
./dhoafparser example.hoaf -v
```

## References

* Specification of the Hanoi Omega-Automata Format: https://adl.github.io/hoaf/
* Source code of the existing C++ parser by the same authors: https://automata.tools/hoa/cpphoafparser/

## License

`dhoafparser` is free software under the [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html).
All rights regarding the Hanoi Omega-Automata format and its C++
parser are reserved to the respective authors (see
[References](#References)).

