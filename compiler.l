%{
	/* to be included after flex defs and includes */

	#include "y.tab.h"
	#include <string.h>
	#include <malloc.h>

	char str[4096];
	char *str_pt;
	long long int nbr;
	int PUT_NL = 1;
	void p(char * pattern)
	{
		printf("%-15s L: %-3d E: %s", pattern, yylineno, yytext);
		PUT_NL && putchar('\n');
	}
%}

%option debug
%option yylineno
%option bison-bridge
%option bison-locations

 /* aliases */

 /*  TODO: add numbers, floats suffixes from 1 or two letters: f,d,l,w,q,i,j,u */
NUMBER		[[:digit:]]+
DECIMAL		"-"?([[:digit:]]{-}[0])[[:digit:]]*
HEXADECIMAL	"-"?0[xX][[:xdigit:]]+
OCTALDECIMAL	"-"?0[0-7]+
FLOAT		{DECIMAL}[.][[:digit:]]+
LETTER		[a-zA-Z]
WORD		{LETTER}+
ID		({LETTER}|_)({WORD}|{NUMBER})*
HEX		[0-9a-fA-F]
CHAR_ENCODED	"\\\\"|"\\\""|"\\'"|"\\n"|"\\t"|"\\f"|"\\v"|"\\r"|"\\a"|"\\b"|"\\x"{HEX}{2}|"\\u"{HEX}{4}|"\\U"{HEX}{8}
CHAR		({CHAR_ENCODED}|[^'])
STRING		"\""({CHAR_ENCODED}|[^\"])*"\""
KEYWORD		if|else|switch|for|while|do|return|case|break|default|continue|goto|sizeof|inline|restrict
TYPE		int|float|double|char|void|_Bool|_Complex|_Imaginary
TYPE_COMPOSED	struct|union|enum|typedef
TYPE_SPECIFIER	short|long|signed|unsigned|register|const|volatile|auto|extern|static
BOOL		"&&"|"||"|"!"|"!="|"=="|">"|"<"|">="|"<="
OPERATOR	"+"|"-"|"*"|"/"|"%"|"&"|"|"|"^"|"~"|"<<"|">>"
OTHER_OPERATOR	{OPERATOR}"="
ONLINE_COMMENT	"//".*$
OTHER		"{"|"}"|"("|")"|"["|"]"|"="|";"|":"|"?"|"."|"&"|","|"->"
MACRO		"#"[ \t]*(if|else|elif|endif|define|undef|pragma|include|ifdef|ifndef|line|error)
SPACE		[ \t\n\r]+

 /* c global defs */
	int	n_others = 0,
		n_spaces = 0,
		n_unknown = 0;

 /* lexer matchings pairs (regex: pattern, c code: action) */

/* %option warn nodefault */
%s state1 state2
%x ML_COMMENT STR ERROR
%%

 /* yy_push_state(STATE), yy_pop_state(), yy_top_state(), %option stack  */
<ML_COMMENT>{
	[^*/]*
	"*"+[^*/]*
	"*"+"/"		{ BEGIN(INITIAL); /*return COMMENT;*/ }
}
<STR>{
	\"		{ BEGIN(INITIAL); yylval->str = strdup(str); return STRING; }
	\n		{ return -1; }
	{CHAR_ENCODED}	|
	\\.		|
	[^\\\n\"]+	{ strcat(str_pt, yytext); }
}
\"			{ BEGIN(STR); str_pt = str; *str_pt = '\0'; }
{ONLINE_COMMENT}	{ yylval->str = strdup(yytext); /*return COMMENT;*/ }
"/*"			{ BEGIN(ML_COMMENT); }
'{CHAR}'		{ yylval->ch = yytext[1]; return CHAR; }
{FLOAT}			{ yylval->flt = atof(yytext); return FLOAT; }
{HEXADECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 16); return NUMBER; /* FIXME */}
{OCTALDECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 8); return NUMBER; /* FIXME */}
{DECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 10); return NUMBER; /* FIXME */}
{KEYWORD}		{ yylval->str = strdup(yytext); return KEYWORD; }
{TYPE}			{ yylval->str = strdup(yytext); return TYPE; }
{TYPE_SPECIFIER}	{ yylval->str = strdup(yytext); return TYPE_SPECIFIER; }
{BOOL}			{ yylval->str = strdup(yytext); return BOOL; }
{OPERATOR}		{ yylval->str = strdup(yytext); return OPERATOR; }
{MACRO}			{ yylval->str = strdup(yytext); return MACRO; }
{ID}			{ yylval->str = strdup(yytext); return ID; }
{SPACE}			{ ++n_spaces; }
.			{ ++n_unknown; return *yytext; }
 /*";"			{ return FP; }*/
 /*"("			{ return LPARAN; }*/
 /*")"			{ return RPARAN; }*/
 /*"="			{ return EQ; }*/
 /*{OTHER}			{ yylval->str = strdup(yytext); return OTHER; }*/

%%

/* main function and bottom code */
/*
int main2(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	int rtn;
	while((rtn = yylex(&yylval)))
		printf("%3d ", rtn);
	printf("\n\nn_others = %d\nn_spaces = %d\nn_unknown = %d\n",
		n_others, n_spaces, n_unknown);
	return 0;
}
*/
