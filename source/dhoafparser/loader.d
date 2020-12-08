module dhoafparser.loader;

import dhoafparser.hoa;

import std.array;
import std.conv : to;

immutable(HOA) loadHOA(immutable string hoabuf, immutable bool verbose) @trusted
{
    auto pt = HOAFormat(hoabuf);

    if(verbose) {
        import std.stdio;
        writeln("--- BEGIN PARSE TREE ---");
        writeln(pt);
        writeln("--- END PARSE TREE ---");
    }

    HOALoader hoaLoader;
    traverse!hoaLoader(pt);

    // generate an immutable HOA struct
    template immutableHOA(alias h)
    {
        auto immutableHOA(immutable bool succ) {
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

struct State {
    uint id;
    alias id this;
}

struct Edge {
    State start;
    State end;
    string label;
    private uint[] _accSets;

    void addAccSets(uint[] as) @safe
    {
        _accSets = as;
    }

    immutable(uint[]) accSets() inout @safe
    {
        return _accSets.idup();
    }

    void dump() inout @safe
    {
        import std.stdio;
        string asb;
        if(accSets.length > 0) {
            asb = " {";
            foreach(as; accSets) {
                asb ~= to!string(as) ~ ", ";
            }
            asb ~= "\b\b";
            asb ~= "}";
        }
        writeln(to!string(start.id) ~ "->" ~ to!string(end.id) ~ " " ~ label ~ " " ~asb);
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
        import std.stdio;
        foreach(State s; startBuf.data()) {
            if(s.id == id) return;
        }
        startBuf.put(State(id));
    }

    immutable(State[]) startSet() immutable @safe {
        return startBuf.data();
    }

    immutable(Edge[]) edges() immutable @safe {
        return edgeBuf.data();
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
        currentEdge.addAccSets(accSetBuf.data.dup());
        edgeBuf.put(currentEdge);
        accSetBuf.clear();
    }
}
