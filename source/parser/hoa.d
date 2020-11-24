module parser.hoa;

import parser.loader;

import pegged.grammar;
import std.conv : to;
import std.stdio;

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
    writeln("currentState " ~ to!string(p.matches[0]));
    hoaLoader.currentState = State(to!uint(p.matches[0]));
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
    writeln("accSet " ~ to!string(p.matches[0]));
    () @trusted { writeln(p); } ();
    hoaLoader.accSet(to!uint(p.matches[0]));
    return p;
}

ParseTree addEdge(alias hoaLoader)(ParseTree p) @safe
{
    hoaLoader.addEdge();
    return p;
}

/**
 * Grammar definition
 */
mixin(grammar(HOAGrammar));

immutable string HOAGrammar = `

HOAFormat:

    automaton      < header "--BODY--" endOfLine* body "--END--"

    header         < formatVersion headerItem*

    body           < (stateName edge*)+

    formatVersion  < "HOA:" IDENTIFIER endOfLine*
    
    headerItem     < "States:" INT { nStates!hoaLoader } endOfLine* 
                    / "Start:" startConj endOfLine* 
                    / "AP:" APList endOfLine*  
                    / "Alias:" ANAME labelExpr endOfLine*
                    / "Acceptance:" INT acceptanceCond endOfLine*
                    / "acc-name:" IDENTIFIER ( BOOLEAN / INT / IDENTIFIER )* endOfLine*
                    / "tool:" STRING STRING? endOfLine* 
                    / "name:" STRING endOfLine*
                    / "properties:" IDENTIFIER* endOfLine*
                    / HEADERNAME ( BOOLEAN / INT / STRING / IDENTIFIER )* endOfLine*

    stateName      <  "State:" label? INT { currentState!hoaLoader } STRING? accSig? endOfLine*

    edge           <  label endState { (p) { writeln(p); return p; }} accSig? { addEdge!hoaLoader } endOfLine* 
    
    label          <  "[" labelExpr { currentEdgeLabel!hoaLoader } "]"

    endState       <  INT { edgeFinalState!hoaLoader }

    accSig         <- "{" ( INT { accSet!hoaLoader } space )+ "}"

    APList         <  INT { nAP!hoaLoader } STRING*

    startConj      <~ INT { start!hoaLoader } / startConj "&" INT { start!hoaLoader }

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
