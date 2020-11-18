module parser.hoa;

import pegged.grammar;

mixin(grammar(`

HOAFormat:

    automaton      < header "--BODY--" endOfLine* body "--END--"

    header         < formatVersion headerItem*

    body           < (stateName edge*)+

    formatVersion  < "HOA:" IDENTIFIER endOfLine*
    
    headerItem     < "States:" INT endOfLine*
                    / "Start:" stateConj endOfLine*
                    / "AP:" INT STRING* endOfLine*
                    / "Alias:" ANAME labelExpr endOfLine*
                    / "Acceptance:" INT acceptanceCond endOfLine*
                    / "acc-name:" IDENTIFIER ( BOOLEAN / INT / IDENTIFIER )* endOfLine*
                    / "tool:" STRING STRING? endOfLine* 
                    / "name:" STRING endOfLine*
                    / "properties:" IDENTIFIER* endOfLine*
                    / HEADERNAME ( BOOLEAN / INT / STRING / IDENTIFIER )* endOfLine*

    stateName      < "State:" label? INT STRING? accSig? endOfLine*

    edge           < label? stateConj accSig? endOfLine*
    
    accSig         < "{" INT* "}"

    label          < "[" labelExpr "]"
    

    stateConj      <~ INT / stateConj "&" INT

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

`));
