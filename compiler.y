%{
#include <stdio.h>

int yylex(void *, void *);
extern FILE *yyin;
extern char *yytext;
extern int yylineno;

void yyerror(const char *str) {
	printf("ERROR: L: %-3d MSG: %s\n", yylineno, str);
}
%}

/*%glr-parser*/
/*%expect-rr 1*/
%debug
%error-verbose
%locations
%pure-parser
%union {
        long long nbr;
	double flt;
        char *str;
        char ch;
}

%token <nbr>	NUMBER
%token <str> 	STRING KEYWORD TYPE COMMENT
		TYPE_SPECIFIER BOOL OPERATOR MACRO ID OTHER
%token <flt>	FLOAT
%token <ch>	CHAR
%token		IF GT LT

/* FIXME */
%destructor { free($$); }  <str>

/* HANDLE THESE ON BISON  { } ( ) [ ] = ; : ? . & , -> */

%start prog

%%
/* expr, stmt, decl, fnct def */
prog	: expr ';' prog
	| decl ';' prog
	| '{' prog '}' prog
	| %empty
	;

decl	: type  sub_dec
	;

sub_dec	: ID
	  {
		printf("ID<%s>\n", $1);
	  }
	| ID ',' sub_dec
	  {
		printf("ID<%s>\n", $1);
	  }
	| ID '=' expr ',' sub_dec
	  {
		printf("ID<%s>\n", $1);
	  }
	| ID '=' expr
	  {
		printf("ID<%s>\n", $1);
	  }

type	: TYPE_SPECIFIER type
	  {
		printf("TYPE_SPECIFIER<%s>\n", $1);
	  }
	| TYPE type
	  {
		printf("TYPE<%s>\n", $1);
	  }
	| %empty
	;

expr	: '(' expr ')'
	| str
	| num
	| chr
	;

num	: NUMBER
	  {
		printf("NUMBER<%lld>\n", $1);
	  }
	| FLOAT
	  {
		printf("FLOAT<%e>\n", $1);
	  }
	| num OPERATOR num
	  {
		printf("OP<%s>\n", $2);
	  }
	| '(' num ')'
	;

str	: str STRING
	  {
		printf("STRING<%s>\n", $2);
	  }
	| STRING
	  {
		printf("STRING<%s>\n", $1);
	  }
	;

chr	: chr CHAR
	  {
		printf("CHAR<%c>\n", $2);
	  }
	| CHAR
	  {
		printf("CHAR<%c>\n", $1);
	  }
	;
%%

int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	yyparse();
	return 0;
}
