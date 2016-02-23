%{
#include <stdio.h>

int yylex(void);

void yyerror(char* str) {
	printf("ERROR: %s\n", str);
}
%}

%union {
        long long nbr;
	double flt;
        char *str;
        char ch;
}

%token <nbr> NUMBER
%token <str> STRING
%token <str> COMMENT
%token <flt> FLOAT
%token <ch> CHAR
%token	IF
	LPARAN RPARAN
	KEYWORD TYPE TYPE_SPECIFIER BOOL OPERATOR MACRO IDENT OTHER

%start ins

%%
ins:	NUMBER
	| STRING
	| COMMENT
	| %empty
	;
