/* description: Parses end executes a very small lisp implementation. */

/* lexical grammar */
%lex

%%
[^\S\n]+                   /* ignore whitespace other than newlines */
\n\s*                      return 'NEWLINE';
[0-9]+("."[0-9]+)?\b       return 'NUMBER';
mul|div|sub|add|pow        return 'BINARY_OPERAND';
sqrt                       return 'UNARY_OPERAND';
"defn"                     return 'DEFINITION';
[a-z]+[0-9]*               return 'IDENTIFIER';
"-"                        return '-';
"("                        return '(';
")"                        return ')';
"["                        return '[';
"]"                        return ']';
<<EOF>>                    return 'EOF';

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%left UMINUS

%start prog

/* declarations */

%{
    var definitionsMap = {}

    function allocateDefinition(definition, param, expression) {
      definitionsMap[definition] = function(value) {
        return eval(expression.replace(param, value))
      }

    }

    function executeDefinition(definition, param) {
      const result = definitionsMap[definition](param)
      return result
    }

    function executeExpression(operand, x, y) {
      var operation = parseOperation(operand, x, y)

      if (typeof x === 'string' || typeof y === 'string') {
        return operation
      }

      return eval(operation)
    }

    function parseOperation(operand, x, y) {
      var parsedOperation;

      switch (operand) {
        case 'mul':
          parsedOperand = x + '*' + y
          break
        case 'div':
          parsedOperand = x + '/' + y
          break
        case 'add':
          parsedOperand =  x + '+' + y
          break
        case 'sub':
          parsedOperand = x + '-' + y
          break
        case 'pow':
          parsedOperand = 'Math.pow(' + x + ',' + y + ')'
          break
        case 'sqrt':
          parsedOperand = 'Math.sqrt(' + x + ')'
          break
      }

      return parsedOperand
    }
%}

%% /* language grammar */

prog
    : exprs EOF
        { return $1 }
    ;

exprs
    :
    | exprs expr
        { console.log($2) }
    ;

expr
    : expr NEWLINE
    | '(' DEFINITION IDENTIFIER '[' IDENTIFIER ']' expr ')'
        %{
            allocateDefinition($3, $5, $7)
            $$ = ''
        %}
    | '(' IDENTIFIER expr ')'
        { $$ = executeDefinition($2, [$3]) }
    | '(' BINARY_OPERAND expr expr ')'
        { $$ = executeExpression($2, $3, $4)}
    | '(' UNARY_OPERAND expr ')'
        { $$ = executeExpression($2, $3)}
    | '(' '-' expr ')' %prec UMINUS
        { $$ = -$3 }
    | '(' expr ')'
        { $$ = $2 }
    | BINARY_OPERAND
        { $$ = yytext }
    | UNARY_OPERAND
        { $$ = yytext }
    | IDENTIFIER
        { $$ = yytext }
    | NUMBER
        { $$ = Number(yytext) }
    ;
