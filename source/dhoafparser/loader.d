module dhoafparser.loader;

import dhoafparser.hoa;

import std.array;
import std.conv : to;

auto parseHOA(immutable string hoabuf, immutable bool verbose) @trusted
{
    auto pt = HOAFormat(hoabuf);

    if(verbose) {
        import std.stdio;
        writeln("--- BEGIN PARSE TREE ---");
        writeln(pt);
        writeln("--- END PARSE TREE ---");
    }

    return pt;
}

immutable(HOA) loadHOA(immutable string hoabuf, immutable bool verbose) @safe
{
    auto pt = parseHOA(hoabuf, verbose);

    HOALoader hoaLoader;
    pt.traverse!hoaLoader();

    // generate an immutable HOA struct
    template immutableHOA(alias h)
    {
        auto immutableHOA(immutable bool succ) @safe {
            immutable hoa = HOA(h, succ);
            destroy(h);
            return hoa;
        }
    }
    typeof(return) hoa = immutableHOA!hoaLoader(pt.successful);

    return hoa;
}

/**
 * HOA data structs.
 */
struct HOA {
    immutable HOALoader hoa;
    immutable bool valid;
    alias hoa this;

    this(HOALoader h, bool succ) @trusted
    {
        hoa = cast(immutable(HOALoader))h;
        valid = succ;
    }
}

enum Acceptance {
    TGBA,
    SGBA
}

immutable string MaccSets = `
    private uint[] _accSets;

    void addAccSets(uint[] as) @safe
    {
        _accSets = as;
    }

    immutable(uint[]) accSets() inout @safe
    {
        return _accSets.idup();
    }
`;

struct State {
    uint id;
    alias id this;
    mixin(MaccSets);

    immutable string dump() inout @safe
    {
        string asb;
        if(accSets.length > 0) {
            asb = " {";
            foreach(as; accSets) {
                asb ~= to!string(as) ~ ", ";
            }
            asb ~= "\b\b";
            asb ~= "}";
        }
        return to!string(id) ~ asb;
    }
}

struct Edge {
    State start;
    State end;
    string label;
    mixin(MaccSets);

    immutable string dump() inout @safe
    {
        string asb;
        if(accSets.length > 0) {
            asb = " {";
            foreach(as; accSets) {
                asb ~= to!string(as) ~ ", ";
            }
            asb ~= "\b\b";
            asb ~= "}";
        }
        return start.dump() ~ "->" ~ end.dump() ~ " " ~ label ~ " " ~asb;
    }
}

struct HOALoader {
    private {
        Appender!(immutable(string[])) APbuf;
        Appender!(immutable(string[])) propBuf;
        Appender!(immutable(State[])) stateBuf;
        Appender!(immutable(Edge[])) edgeBuf;
        Appender!(immutable(State[])) startBuf;
        Appender!(uint[]) accSetBuf;
    }

    // TODO support extra headers & ALIAS
    string name;
    Edge currentEdge;
    uint nStates;
    uint nAP;
    uint nAccSets;
    string acceptanceString;
    string toolString;
    Acceptance acceptance;

    void atomicProposition(immutable string aprop) @safe {
        APbuf.put(aprop);
    }

    immutable(string[]) atomicPropositions() immutable @safe {
        return APbuf.data();
    }

    void atomicProp(immutable string aprop) @safe {
        propBuf.put(aprop);
    }

    immutable(string[]) atomicProps() immutable @safe {
        return propBuf.data();
    }

    void state(immutable uint id) @safe {
        stateBuf.put(State(id));
    }

    immutable(State[]) states() immutable @safe {
        return stateBuf.data();
    }

    void start(immutable uint id) @safe {
        foreach(uint sid; startBuf.data()) {
            if(sid == id) return;
        }
        startBuf.put(State(id));
    }

    immutable(State[]) startSet() immutable @safe {
        return startBuf.data();
    }

    immutable(Edge[]) edges() immutable @safe {
        return edgeBuf.data();
    }

    void TGBA() @safe {
        acceptance = Acceptance.TGBA;
    }

    void SGBA() @safe {
        acceptance = Acceptance.SGBA;
    }

    /**
     * Edge-building utilities
     */
    void accSet(immutable uint id) @safe
    {
        accSetBuf.put(id);
    }

    void addEdge() @safe
    {
        if(acceptance == Acceptance.TGBA) {
            currentEdge.addAccSets(accSetBuf.data.dup());
            accSetBuf.clear();
        } else if(acceptance == Acceptance.SGBA) {
            currentEdge.start.addAccSets(accSetBuf.data.dup());
            accSetBuf.clear();
        }
        edgeBuf.put(currentEdge);
    }
}
