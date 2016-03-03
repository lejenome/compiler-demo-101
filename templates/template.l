%{
	/* to be included after flex defs and includes */
	#include "template.tab.h"
	#include <string.h>
	#include <malloc.h>
%}

%option warn
%option yylineno
%option noyywrap
%option bison-bridge
%option bison-locations


 /* aliases */
NUMBER		[0-9]+


%%
 /* pattern -> action definitions */
 /*{NUMBER}		{ printf("%d", atoi(yytext)); }*/
{NUMBER}		{ yylval->val = strtol(yytext, NULL, 10); return NUMBER; }
[ \t\r]
.|\n			{ return *yytext; }
 /*.			{}*/
%%


 /* main function and bottom code */
/*
int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	while((rtn = yylex(&yylval)))
		printf("%3d ", rtn);
	return 0;
}
*/
