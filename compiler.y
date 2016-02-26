%{
#include <stdio.h>
#include <string.h>

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
/*%define api.value.type {double}*/
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
%token		_EOF_ 0 "end of file"
%token		IF GT LT

%left '-' '+' /* FROM LOWER */
%left '*' '/' /* TO HIGHER */
/* %right 'X' */
/* %nonassoc 'X' */

%type <flt> num
%type <str> str
%type <ch> chr

/* FIXME */
%destructor { free($$); }  <str>

/* HANDLE THESE ON BISON  { } ( ) [ ] = ; : ? . & , -> */

%start prog

%%
/* ... %dprec 1 */
/* ... %merge <MergeFnct> */
/* %?{ !false } "..." */
/* { if(!false) YYERROR; } "..." */
/* expr, stmt, decl, fnct def */
prog	: expr ';' prog
	| decl ';' prog
	| stmt prog
	| block prog
	| _EOF_
	| %empty
	;

block	: '{' prog '}'
	;

stmt	: KEYWORD '(' expr ')' block

decl	: type  sub_decs
	;

sub_decs: sub_dec ',' sub_decs
	| sub_dec
	;

sub_dec	: ID
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
	| ID '[' num ']'
	  {
		printf("ARRAY<%s,%g>\n", $1, $3);
	  }
	;

type	: type_sp TYPE type_sp
	  {
		printf("TYPE<%s>\n", $2);
	  }
	| type_sp
	;

type_sp	: TYPE_SPECIFIER type_sp
	  {
		printf("TYPE_SPECIFIER<%s>\n", $1);
	  }
	| %empty
	;

expr	: '(' expr ')'
	| str
	  {
		printf("VALUE<%s>\n", $1);
	  }
	| num
	  {
		printf("VALUE<%d>\n", $1);
	  }
	| chr
	  {
		printf("VALUE<%c>\n", $1);
	  }
	| ID '[' num ']'
	| ID '=' expr
	;

num	: NUMBER
	  {
		printf("NUMBER<%lld>\n", $1);
		$$ = $1;
	  }
	| FLOAT
	  {
		printf("FLOAT<%e>\n", $1);
		/* $$ = $1; */
	  }
	| num OPERATOR num
	  {
		printf("OP<%s>:%d:%d:%d:%d\n", $2, @$.first_line, @$.first_column, @$.last_line, @$.last_column);
		/* TODO: get value of $$ */
	  }
	| '(' num ')'
	  {
		$$ = $2;
	  }
	;

str	: str STRING
	  {
		printf("STRING<%s>\n", $2);
		$$ = malloc(sizeof(char) * (strlen($1) + strlen($2) + 1));
		strcpy($$, $1);
		strcat($$, $2);
	  }
	| STRING
	  {
		printf("STRING<%s>\n", $1);
		$$ = strdup($1);
	  }
	;

chr	: chr OPERATOR chr
	  {
		printf("OP<%s>\n", $2);
		/* TODO: get value of $$ */
	  }
	| CHAR
	  {
		printf("CHAR<%c>\n", $1);
		/* $$ = $1; */
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
