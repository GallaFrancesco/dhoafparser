module parser.loader;

import pegged.grammar;

import std.array;
import std.conv : to;

/**
 * Global HOA definition (waiting for Pegged external actions...)
 */
template immutableHOA(alias h)
{
    auto immutableHOA() {
        immutable hoa = HOA(h);
        return hoa;
    }
}

struct HOA {
    immutable HOALoader hoa;
    alias hoa this;
    this(HOALoader h) { hoa = cast(immutable(HOALoader))h; }
}

/**
 * HOA data structs.
 */

HOALoader hoaLoader;

struct State {
    uint id;
}

struct Edge {
    State start;
    State end;
    string label;
}

struct HOALoader {
    private {
        Appender!(immutable(string[])) APbuf;
        Appender!(immutable(string[])) propBuf;
        Appender!(immutable(State[])) stateBuf;
        Appender!(immutable(Edge[])) edgeBuf;
        Appender!(immutable(State[])) startBuf;
        Appender!(immutable(State[])) accStateBuf;
    }

    // TODO support extra headers & ALIAS
    string name;
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
        startBuf.put(State(id));
    }

    immutable(State[]) startSet() immutable @safe {
        return startBuf.data();
    }

    void accState(immutable uint id) @safe {
        accStateBuf.put(State(id));
    }

    immutable(State[]) accStates() immutable @safe {
        return accStateBuf.data();
    }

    void edge(immutable State start, immutable State end, immutable string label) @safe {
        edgeBuf.put(Edge(start,end,label));
    }

    immutable(Edge[]) edges() immutable @safe {
        return edgeBuf.data();
    }
}
