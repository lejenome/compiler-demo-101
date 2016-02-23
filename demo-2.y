%{
#include <stdio.h>

int yylex(void);

void yyerror(char* str) {
	printf("ERROR: %s\n", str);
}
%}

%union {
        int number;
        char *string;
        char var;
}

%token <number> NUMBER
%token <string> STRING
%token <string> COMMENT
%token <var> VAR_NUM
%token <var> VAR_STR
%token	IF
	LPARAN RPARAN
	CHAR FLOAT INT KEYWORD TYPE TYPE_SPECIFIER BOOL OPERATOR MACRO IDENT OTHER

%start ins

%%
ins:	NUMBER
	| STRING
	| COMMENT
	| %empty
	;
