%code top {
	// to be inserted to top of source file
	#include <stdio.h>
	#include <string.h>
	#include <math.h>

	extern FILE *yyin;
	extern char *yytext;
	extern int yylineno;
	extern int yylex(void *, void *);

	void yyerror(const char *str) {
		printf("ERROR: LINE: %-3d MSG: %s\n", yylineno, str);
	}
}
%code requires {
	// to be inserted to top of the header and source
}
%code provides {
	// to be inserted to the bottom of the header and source
}

%define api.pure true
%define parse.trace true
%locations
/*%glr-parser*/
/*%expect-rr 1*/

%union {
	int val;
}

%token	<val>	NUMBER

%left '-' '+'	/* FROM LOWER */
%left '*' '/'	/* TO HIGHER */

%type <val>	expr prog

%start prog

%%
/* ... %dprec 1 */
/* ... %merge <MergeFnct> */
/* %?{ !false } "..." */
/* { if(!false) YYERROR; } "..." */
/* expr, stmt, decl, fnct def */
prog	: prog ';' prog
	| prog '\n' prog
	| expr
	  {
		printf("%d\n", $1);
	  }
	| %empty
	  {
		$$ = 0;
	  }
	;

expr	: NUMBER
	| expr '+' expr
	  {
		$$ = $1 + $3;
	  }
	| expr '-' expr
	  {
		$$ = $1 - $3;
	  }
	| expr '*' expr
	  {
		$$ = $1 * $3;
	  }
	| expr '/' expr
	  {
		$$ = $1 / $3;
	  }
	| '(' expr ')'
	  {
		$$ = $2;
	  }
	;
%%

int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	return yyparse();
}
