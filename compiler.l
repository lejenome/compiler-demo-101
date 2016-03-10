%{
	/* to be included after flex defs and includes */

	#include "compiler.tab.h"
	#include <string.h>
	#include <malloc.h>

	char str[4096];
	char *str_pt;
	long long int nbr;
	int PUT_NL = 1;
	void p(char * pattern)
	{
		printf("%-15s L: %-3d E: %s", pattern, yylineno, yytext);
		if(PUT_NL)
			putchar('\n');
	}
%}

%option outfile="compiler.lex.c"
/*%option header-file="compiler.lex.h"*/
/*%option tables-file="compiler.lex.dfa"*/
/*%option debug*/
%option backup
%option perf-report
%option nodefault
%option warn
/*%option verbose*/
%option yylineno
%option bison-bridge
%option bison-locations
%option noyywrap

 /* aliases */

 /*  TODO: add numbers, floats suffixes from 1 or two letters: f,d,l,w,q,i,j,u */
ID		[[:alpha:]_][[:alnum:]_]*
/* + universal chars in id \uhhhh */
NUMBER		[[:digit:]]+
DECIMAL		([[:digit:]]{-}[0])[[:digit:]]*
HEXADECIMAL	0[xX][[:xdigit:]]+
BIDECIMAL	0[bB][01]+
OCTALDECIMAL	0[0-7]+
/* + suffix: [uU]?[lL]{,2} and [lL]{,2}[uU]? -- page 66 */
FLOAT_DEC	({DECIMAL}([.][[:digit:]]*)?|[.][[:digit:]]+)([eE][+-]?[[:digit:]]+)?
/* FLOAT_HEX	*/
/* suffix: [fFlL] -- page 69 */
LETTER		[a-zA-Z]
WORD		{LETTER}+
CHAR_ENCODED	"\\\\"|"\\\""|"\\'"|"\\n"|"\\t"|"\\f"|"\\v"|"\\r"|"\\a"|"\\b"|"\""|"\?"|"\\"[0-7]{1,3}|"\\x"[[:xdigit:]]{2}|"\\u"[[:xdigit:]]{4}|"\\U"[[:xdigit:]]{8}
CHAR		({CHAR_ENCODED}|[^'])
/* octal encodin <= \377 */
/* multi char integer */
/* \x(h+) */
STRING		"\""({CHAR_ENCODED}|[^\"])*"\""
KEYWORD		if|else|switch|for|while|do|return|case|break|default|continue|goto|sizeof|inline|restrict
TYPE		int|float|double|char|void|_Bool|_Complex|_Imaginary
TYPE_COMPOSED	struct|union|enum|typedef
TYPE_SPECIFIER	short|long|signed|unsigned|register|const|volatile|auto|extern|static
TYPE_LINKAGE	extern|static
/* |auto */
TYPE_SIGN	unsigned|signed
/* float, double, long double */
/* char, signed char, unsigned char */
/* short int, int, long int, long long int */
TYPE_QUALIFIER	const|volatile|restrict
BOOL		"&&"|"||"|"!"|"!="|"=="|">"|"<"|">="|"<="
RL_OPERATOR	"+"|"-"|"*"|"/"|"%"
BITWISE_OPERATOR	"&"|"|"|"^"|"~"|"<<"|">>"
OTHER_OPERATOR	{OPERATOR}"="
ONLINE_COMMENT	"//".*$
/* more than one line comment using "\" at the end of line or event "\\<\n>\" */
OTHER_PUNCTUATOR	"{"|"}"|"("|")"|"["|"]"|"."|"->"|"="|";"|":"|"?"|"&"|","
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
{HEXADECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 16); return NUMBER; /* FIXME */}
{OCTALDECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 8); return NUMBER; /* FIXME */}
{BIDECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 2); return NUMBER; /* FIXME */}
{DECIMAL}		{ yylval->nbr = strtoll(yytext, NULL, 10); return NUMBER; /* FIXME */}
{FLOAT_DEC}		{ yylval->flt = atof(yytext); return FLOAT; }
{KEYWORD}		{ yylval->str = strdup(yytext); return KEYWORD; }
{TYPE}			{ yylval->str = strdup(yytext); return TYPE; }
{TYPE_SPECIFIER}	{ yylval->str = strdup(yytext); return TYPE_SPECIFIER; }
{BOOL}			{ yylval->str = strdup(yytext); return BOOL; }
{RL_OPERATOR}		{ yylval->ch = *yytext; return RL_OPERATOR; }
{BITWISE_OPERATOR}	{ yylval->str = strdup(yytext); return BL_OPERATOR; }
{MACRO}			{ yylval->str = strdup(yytext); return MACRO; }
{ID}			{ yylval->str = strdup(yytext); return ID; }
{SPACE}			{ ++n_spaces; yy_flex_debug = 0; }
.			{ ++n_unknown; return *yytext; }
 /*";"			{ return FP; }*/
 /*"("			{ return LPARAN; }*/
 /*")"			{ return RPARAN; }*/
 /*"="			{ return EQ; }*/
 /*{OTHER}			{ yylval->str = strdup(yytext); return OTHER; }*/
 <<EOF>>		{ return _EOF_; }

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
