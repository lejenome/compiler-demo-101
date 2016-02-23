%{
	/* to be included after flex defs and includes */

	#include "y.tab.h"
	#include <string.h>
	#include <malloc.h>

	int PUT_NL = 1;
	void p(char * pattern)
	{
		printf("%-15s L: %-3d E: %s", pattern, -1, yytext);
		PUT_NL && putchar('\n');
	}
%}


 /* aliases */

 /*  TODO: add numbers, floats suffixes from 1 or two letters: f,d,l,w,q,i,j,u */
DIGIT		[0-9]
NUMBER		{DIGIT}+
INT		-?{NUMBER}
FLOAT		{INT}"."{NUMBER}
LETTER		[a-zA-Z]
WORD		{LETTER}+
IDENT		({LETTER}|_)({WORD}|{NUMBER})*
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
SPACE		[ \t\n]+

 /* c global defs */
	int	n_others = 0,
		n_spaces = 0,
		n_unknown = 0;

 /* lexer matchings pairs (regex: pattern, c code: action) */

%s state1 state2
%x ML_COMMENT STR ERROR
%%

<ML_COMMENT>{
	[^*/]*
	"*"+[^*/]*
	"*"+"/"		{ BEGIN(INITIAL); return COMMENT; }
}
<STR>{
	\"		{ BEGIN(INITIAL); return STRING; }
	\n		{ return -1; }
	CHAR_ENCODED
	\\.
	[^\\\n\"]+
}
\"			{ BEGIN(STR); }
 /*{STRING}		{ p("STRING"); }*/
{ONLINE_COMMENT}	{ return COMMENT; }
"/*"			{ BEGIN(ML_COMMENT); return COMMENT; }
'{CHAR}'		{ return CHAR; }
{FLOAT}			{ return FLOAT; }
{INT}			{ return INT; }
{KEYWORD}		{ return KEYWORD; }
{TYPE}			{ return TYPE; }
{TYPE_SPECIFIER}	{ return TYPE_SPECIFIER; }
{BOOL}			{ return BOOL; }
{OPERATOR}		{ return OPERATOR; }
{MACRO}			{ return MACRO; }
{IDENT}			{ return IDENT; }
{OTHER}			{ return OTHER; }
{SPACE}			{ ++n_spaces; }
.			{ ++n_unknown; return -1; }

%%

/* main function and bottom code */
int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	int rtn;
	while((rtn = yylex()))
		printf("%3d ", rtn);
	printf("\n\nn_others = %d\nn_spaces = %d\nn_unknown = %d\n",
		n_others, n_spaces, n_unknown);
	return 0;
}
