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
{NUMBER}		{ yylval->val = strtol(yytext, NULL, 10); return NUMBER; }
[ \t\r]
.|\n			{ return *yytext; }
%%
