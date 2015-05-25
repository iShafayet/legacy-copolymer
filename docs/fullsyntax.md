

Syntax Grammar
=======

{string} -> absolutely anything 

{blockscope} -> a blockscope is basically an indented block. exactly like coffeescript or python.

{indent} -> two consecutive spaces

{javascript-expression} -> standard javascript expression,

{comments} -> any content followed by a hash (#) until a newline is found. must not work inside a string.

{commented-block} -> anything in between two (###) sequences, must not work inside a string.



{identifier} = (a-zA-Z0-9-)+



{code-fragment}

{code-fragment} = {full-statement}*

{full-statement} = ({indent}*){statement}({linebreak})

{statement} = {preprocessor-directive}|{copoly-statement}|{cohtml-statement}




{preprocessor-directive} = {include-statement}|{region-statement}|{insert-statement}

{include-statement} = @include "{string}"

{region-statement} = @region {identifier} {blockscope}

{insert-statement} = @insert {identifier}





{copoly-statement} = {if-statement}|{unless-statement}|{bind-statement}|{for-statement}|{define-statement}|{exlcude-statement}

{if-statement} = if {javascript-expression}

{unless-statement} = unless {javascript-expression}

{bind-statement} = bind ({javascript-expression} as {identifier})*

{define-statement} = define {identifier}

{exlcude-statement} = exclude

{for-statement} = {for-in-statement}|{for-of-statement}

{for-in-statement} = {for-item-in-expr-statement}|{for-item-index-in-expr-statement}

{for-of-statement} = {for-key-of-expr-statement}|{for-key-value-of-expr-statement}

{for-item-in-expr-statement} = for {identifier} in {javascript-expression}

{for-item-index-in-expr-statement} = for {identifier}, {identifier} in {javascript-expression}

{for-key-of-expr-statement} = for {identifier} of {javascript-expression}

{for-key-value-of-expr-statement} = for {identifier}, {identifier} of {javascript-expression}




{cohtml-statement} = {tag} ({attribute}(={attribute-value})?)* (`{string}`)?

{tag} = ({identifier}*!*)+

{attribute} = {identifier}

{attribute-value} = "{string}"





Syntax Higlighting ()
====

comment

commented-block

keywords -> if, unless, bind, as, define, exclude, for, in, of

directives -> @include, @region, @insert

operators "=" "," "+" "-" "<" ">" "/" "*" "%" "!" (inside javascript expression)

identifier

tag

attribute

attribute-value








