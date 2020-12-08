module dhoafparser.hoa;

import pegged.grammar;
import std.conv : to;
import std.stdio;

void traverse(alias hoaLoader)(ParseTree p) @trusted
{
    switch(p.name) {
    case "HOAFormat.NSTATES":
        nStates!hoaLoader(p);
        break;
    case "HOAFormat.NAP":
        nAP!hoaLoader(p);
        break;
    case "HOAFormat.CURRENTSTATE":
        currentState!hoaLoader(p);
        break;
    case "HOAFormat.ENDSTATE":
        edgeFinalState!hoaLoader(p);
        break;
    case "HOAFormat.STARTSTATE":
        start!hoaLoader(p);
        break;
    case "HOAFormat.ACCSET":
        accSet!hoaLoader(p);
        break;
    case "HOAFormat.edgeLabelExpr":
        currentEdgeLabel!hoaLoader(p);
        break;
    case "HOAFormat.edge":
        addEdge!hoaLoader(p);
        break;
    default:
        break;
    }
    foreach(c; p.children) traverse!hoaLoader(c);
}

/**
 * Grammar definition
 */
mixin(grammar(HOAGrammar));

immutable string HOAGrammar = `

HOAFormat:

    automaton      < header "--BODY--" endOfLine* body "--END--"

    header         < formatVersion headerItem*

    body           <- (stateName edge*)+

    formatVersion  < "HOA:" IDENTIFIER endOfLine*
    
    headerItem     < "States:" NSTATES endOfLine* 
                    / "Start:" startConj endOfLine* 
                    / "AP:" APList endOfLine*  
                    / "Alias:" ANAME labelExpr endOfLine*
                    / "Acceptance:" INT acceptanceCond endOfLine*
                    / "acc-name:" IDENTIFIER ( BOOLEAN / INT / IDENTIFIER )* endOfLine*
                    / "tool:" STRING STRING? endOfLine* 
                    / "name:" STRING endOfLine*
                    / "properties:" IDENTIFIER* endOfLine*
                    / HEADERNAME ( BOOLEAN / INT / STRING / IDENTIFIER )* endOfLine*

    stateName      <  "State:" label? CURRENTSTATE STRING? accSig? endOfLine*

    edge           <  edgeLabel ENDSTATE accSig? { } endOfLine*

    label          <  "[" labelExpr "]"
    edgeLabel      <  "[" edgeLabelExpr "]"

    accSig         < "{" ( !"}" ACCSET )+ "}"

    APList         <  NAP STRING*

    startConj      < STARTSTATE / startConj "&" STARTSTATE 

    edgeLabelExpr  <  labelExpr
    labelExpr      < "!" labelExpr
                    / "(" labelExpr ")"
                    / labelExpr "&" labelExpr
                    / labelExpr "|" labelExpr
                    / BOOLEAN
                    / INT
                    / ANAME

    acceptanceCond <- "(" acceptanceCond ")"
                    / acceptanceCond "&" acceptanceCond
                    / acceptanceCond "|" acceptanceCond
                    / IDENTIFIER '(' '!'? INT ')'
                    / BOOLEAN

    HEADERNAME     <~ identifier ":"
  
    ANAME          <~ "@" identifier
   
    IDENTIFIER     <~ [a-zA-Z_] [a-zA-Z_0-9-]*

    BOOLEAN        <~ TT / FF

    COMMENT        <- CommStart (!CommEnd .)* CommEnd

    NSTATES        <~ INT
    NAP            <  INT
    ACCSET         <  INT
    CURRENTSTATE   <~ INT
    ENDSTATE       <  INT
    STARTSTATE     <  INT

    INT            <~ digit+

    STRING         <~ doublequote (DQChar)* doublequote

    DQChar         <- EscapeSequence / !doublequote .

    EscapeSequence <~ backslash ( quote
                                / doublequote
                                / backslash
                                / [abfnrtv]
                                )

    TT             <- "t"

    FF             <- "f"

    CommStart      <- slash "*"

    CommEnd        <- "*" slash

    Spacing        <- (space / COMMENT)*

`;

private:
import dhoafparser.loader : State, Edge, HOALoader;

/**
 * Semantic actions
 */
ParseTree nStates(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    hoaLoader.nStates = to!uint(p.matches[0]);
    return p;
}

ParseTree start(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    import std.stdio;
    hoaLoader.start(to!uint(p.matches[0]));
    return p;
}


ParseTree nAP(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    hoaLoader.nAP = to!uint(p.matches[0]);
    return p;
}

ParseTree currentState(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    hoaLoader.currentEdge.start = State(to!uint(p.matches[0]));
    return p;
}

ParseTree currentEdgeLabel(alias hoaLoader)(ParseTree p) @safe
{
    hoaLoader.currentEdge.label = to!string(p.matches);
    return p;
}

ParseTree edgeFinalState(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    hoaLoader.currentEdge.end = State(to!uint(p.matches[0]));
    return p;
}

ParseTree accSet(alias hoaLoader)(ParseTree p) @safe
{
    assert(p.matches.length == 1);
    hoaLoader.accSet(to!uint(p.matches[0]));
    return p;
}

ParseTree addEdge(alias hoaLoader)(ParseTree p) @safe
{
    hoaLoader.addEdge();
    return p;
}

