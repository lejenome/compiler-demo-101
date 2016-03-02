%code top {
	// to be inserted to top of source file
	#include <stdio.h>
	#include <string.h>
	#include <math.h>

	extern FILE *yyin;
	extern char *yytext;
	extern int yylineno;

	struct symrec *syms = NULL;
	void* getsym(char*);
	void putsym(char*, double (*)(double));
	void yyerror(const char *str) {
		printf("ERROR: L: %-3d MSG: %s\n", yylineno, str);
	}
	float math_exc(float x, char op, float y);
}
%code requires {
	// to be inserted to top of the header and source
	struct symrec {
		char* name;
		double (*fnct)(double);
		struct symrec *next;
	};
}
%code provides {
	// to be inserted to the bottom of the header and source
}

%define api.pure true
%define parse.trace true
/*%glr-parser*/
/*%expect-rr 1*/
%debug
%verbose
%error-verbose
%locations
/*%define api.value.type {double}*/
/*%define api.token.prefix {TK_}*/
%union {
        long long nbr;
	double flt;
}
%union {
        char *str;
        char ch;
}

%token <nbr>	NUMBER
%token <str> 	STRING KEYWORD TYPE COMMENT
		TYPE_SPECIFIER BOOL MACRO OTHER
		BL_OPERATOR
%token <flt>	FLOAT
%token <ch>	CHAR
		RL_OPERATOR
%token <str>	ID
%token		_EOF_ 0 "end of file"
%token		IF	"if"
%token		GT	'>'
%token		LT	'<'

%precedence '='
%left '-' '+' /* FROM LOWER */
%left '*' '/'
%precedence NEG
%right '^'    /* TO HIGHEST */
/* %nonassoc 'X' */

%type <flt> num
%type <str> str
%type <ch> chr

/* FIXME */
%destructor	{ free($$); }		<str>
%printer	{ fprintf(yyoutput, "-----%s\n", $$); }	<str>
%printer	{ fprintf(yyoutput, "-----%g\n", $$); }	<flt>

/* HANDLE THESE ON BISON  { } ( ) [ ] = ; : ? . & , -> */
%{
	int yylex(YYSTYPE *, YYLTYPE *);
%}

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
/*	| error ';' {yyerrok;}*/
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
		printf("VALUE<%g>\n", $1);
	  }
	| chr
	  {
		printf("VALUE<%c>\n", $1);
	  }
	| ID '[' num ']'
	| ID '=' expr
	| ID '(' expr ')'
	  {
		double (*f)(double) = getsym($1);
		if (NULL)
			YYERROR;
		else
			(*f)(0);
	  }
	;

num	: NUMBER
	  {
		printf("NUMBER<%lld>\n", $1);
		$$ = (double)$1;
	  }
	| FLOAT
	  {
		printf("FLOAT<%g>\n", $1);
	  }
	| num RL_OPERATOR num
	  {
		printf("OP<%c>:%d:%d:%d:%d\n", $2, @$.first_line, @$.first_column, @$.last_line, @$.last_column);
		$$ = math_exc($1, $2, $3);
	  }
	| '(' num ')'
	  {
		$$ = $2;
	  }
	| RL_OPERATOR num	%prec NEG
	  { switch($1) {
		case '+': $$ = $2; break;
		case '-': $$ = - $2; break;
		default: YYERROR;
	  }}
	| ID '(' num ')'
	  {
		double (*f)(double) = getsym($1);
		if (NULL)
			YYERROR;
		else
			$$ = (*f)((double)$3);
		printf("FNCT<%s(%g),%g>\n", $1, (double)$3, $$);
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

chr	: chr RL_OPERATOR chr
	  {
		printf("OP<%c>\n", $2);
		/* TODO: get value of $$ */
		$$ = (char)math_exc((float)$1, $2, (float)$3);
	  }
	| CHAR
	  {
		printf("CHAR<%c>\n", $1);
	  }
	;
%%

float math_exc(float x, char op, float y) {
	switch(op) {
	case '+': return x + y; break;
	case '-': return x - y; break;
	case '*': return x * y; break;
	case '/': return x / y; break;
	case '%': return (int)x % (int)y; break;
	default:  return 0;
	}
}
void* getsym(char* n)
{
	struct symrec *s = syms;
	while(s && strcmp(s->name,n) != 0)
		s = s->next;
	if(s)
		return s->fnct;
	return NULL;
}
void putsym(char *n, double (*f)(double))
{
	struct symrec *s = syms;
	while(s && strcmp(s->name,n) != 0)
		s = s->next;
	if(s)
		return;
	s = malloc(sizeof(struct symrec));
	s->name = strdup(n);
	s->fnct = f;
	s->next = syms;
	syms = s;
}
int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	putsym("cos", cos);
	putsym("ceil", ceil);
	putsym("exp", exp);
	putsym("exp2", exp2);
	putsym("log", log);
	putsym("log10", log10);
	putsym("log2", log2);
	putsym("sin", sin);
	putsym("sqrt", sqrt);
	putsym("tan", tan);
	return yyparse();
}
