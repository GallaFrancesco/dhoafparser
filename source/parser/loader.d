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
    alias id this;
}

struct Edge {
    State start;
    State end;
    string label;
    immutable(State[]) accSetBuf;

    this(immutable State s, immutable State e, immutable string l, immutable(State[]) ab) @safe {
        start = s;
        end = e;
        label = l;
        accSetBuf = ab;
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
    State currentState;
    Edge currentEdge;
    uint nStates;
    uint nAP;
    uint nAccSets;
    string acceptanceString;
    string toolString;

    void addEdge() @safe
    {
        edgeBuf.put(currentEdge);
        accSetBuf.clear();
    }

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

    void start(immutable uint id) @safe { // TODO ugly solution but startBuf is supposed to be small
        foreach(State s; startBuf.data()) {
            if(s.id == id) return;
        }
        startBuf.put(State(id));
    }

    immutable(State[]) startSet() immutable @safe {
        return startBuf.data();
    }

    void accSet(immutable uint id) @safe {
        accSetBuf.put(id);
    }

    immutable(uint[]) accSets() immutable @safe {
        return accSetBuf.data();
    }

    immutable(Edge[]) edges() immutable @safe {
        return edgeBuf.data();
    }
}
