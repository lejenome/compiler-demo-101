%{
	/* to be included after flex defs and includes */
	#include <string.h>
	#include <malloc.h>
%}

%option warn
%option yylineno
%option noyywrap


 /* aliases */
NUMBER		[0-9]+


%%
 /* pattern -> action definitions */
{NUMBER}		{ printf("%d", atoi(yytext)); }
.
%%


 /* main function and bottom code */
int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	return yylex();
}
