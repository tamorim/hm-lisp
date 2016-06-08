/* description: Parses end executes a very small lisp implementation. */

/* lexical grammar */
%lex

%%
[^\S\n]+              /* ignore whitespace other than newlines */
\n\s*                 return 'NEWLINE';
[0-9]+("."[0-9]+)?\b  return 'NUMBER';
"mul"                 return '*';
"div"                 return '/';
"sub"                 return '-';
"-"                   return '-';
"add"                 return '+';
"pow"                 return '^';
"("                   return '(';
")"                   return ')';
<<EOF>>               return 'EOF';

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%left UMINUS

%start prog

%% /* language grammar */

prog
    : exprs EOF
        {return $1;}
    ;

exprs
    :
    | exprs expr
        {console.log($2);}
    ;

expr
    : expr NEWLINE
    | '(' '+' expr expr ')'
        {$$ = $3 + $4;}
    | '(' '-' expr expr ')'
        {$$ = $3 - $4;}
    | '(' '*' expr expr ')'
        {$$ = $3 * $4;}
    | '(' '/' expr expr ')'
        {$$ = $3 / $4;}
    | '(' '^' expr expr ')'
        {$$ = Math.pow($3, $4);}
    | '(' '-' expr ')' %prec UMINUS
        {$$ = -$3;}
    | '(' expr ')'
        {$$ = $2;}
    | NUMBER
        {$$ = Number(yytext);}
    ;
