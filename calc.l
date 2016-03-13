%{
	/* to be included after flex defs and includes */
	#include "calc.tab.h"
	#include <string.h>
	#include <malloc.h>
%}

%option warn
%option yylineno
%option noyywrap
%option bison-bridge
%option bison-locations


 /* aliases */
DECIAML		[1-9][0-9]*
HEX		0[xX][0-9]+
OCTAL		0[0-7]*
BIN		0b[01]+
ID		[_a-zA-Z][_a-zA-Z0-9]*
OP		"+"|"-"|"/"|"*"|"%"


%%
 /* pattern -> action definitions */
if			{ return IF; }
for			{ return FOR; }
else			{ return ELSE; }

{DECIAML}		{ yylval->val = strtoll(yytext, NULL, 10); return NUMBER; }
{HEX}			{ yylval->val = strtoll(yytext, NULL, 16); return NUMBER; }
{OCTAL}			{ yylval->val = strtoll(yytext, NULL, 8); return NUMBER; }
{BIN}			{ yylval->val = strtoll(yytext, NULL, 2); return NUMBER; }
{ID}			{ yylval->id = strdup(yytext); return ID; }
"++"			{ return PP; }
"--"			{ return MM; }
"<="			{ return LE; }
">="			{ return GE; }
"=="			{ return EQ; }
"!="			{ return NE; }
"&&"			{ return B_AND; }
"||"			{ return B_OR;}
[ \t\r]
.|\n			{ return *yytext; }
%%
