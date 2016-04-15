%code top {
	// to be inserted to top of source file
	#include <stdio.h>
	#include <string.h>
	#include <math.h>

	extern FILE *yyin;
	extern char *yytext;
	extern int yylineno;
	extern int yylex(void *, void *);

	void yyerror(const char *str) {
		printf("[ERROR:%d] %s\n", yylineno, str);
	}
	struct symtab {
		char *id;
		long long int val;
		struct symtab *next;
	};
	struct symtab *syms = NULL;
	struct symtab *putsym(char *);
	long long int getsym(char *);
}
%code requires {
	// to be inserted to top of the header and source
}
%code provides {
	// to be inserted to the bottom of the header and source
}

%define api.pure true
%define parse.trace true
%locations
/*%glr-parser*/
/*%expect-rr 1*/

%union {
	long long int val;
	char *id;
}

%token	<val>	NUMBER
%token	<id>	ID
%token	MM "--"
%token	PP "++"
%token	IF FOR ELSE
%token	LE "<="
%token	GE ">="
%token	EQ "=="
%token	NE "!="
%token	B_AND "&&"
%token	B_OR "||"

%left ';' '\n'
%left "||" "&&"
%left "<=" ">=" "==" "!=" '<' '>'
%left '-' '+'	/* FROM LOWER */
%left '*' '/'	/* TO HIGHER */

%type <val>	expr assig

%start prog

%%
prog	: prog ';' prog
	| prog '\n' prog
	| expr
	  {
		printf("%lld\n", $1);
	  }
	| assig
	/*| stmt*/
	| %empty
	;

assig	: ID '=' expr
	  {
		putsym($1)->val = $3;
		$$ = $3;
	  }

expr	: NUMBER
	| ID
	  {
		$$ = getsym($1);
	  }
	| "--" ID
	  {
		$$ = --(putsym($2)->val);
	  }
	| ID "--"
	  {
		$$ = (putsym($1)->val)--;
	  }
	| "++" ID
	  {
		$$ = ++(putsym($2)->val);
	  }
	| ID "++"
	  {
		$$ = (putsym($1)->val)++;
	  }
	| expr '+' expr
	  {
		$$ = $1 + $3;
	  }
	| expr '-' expr
	  {
		$$ = $1 - $3;
	  }
	| expr '*' expr
	  {
		$$ = $1 * $3;
	  }
	| expr '/' expr
	  {
		$$ = $1 / $3;
	  }
	| expr '<' expr
	  {
		$$ = $1 < $3;
	  }
	| expr '>' expr
	  {
		$$ = $1 > $3;
	  }
	| expr "<=" expr
	  {
		$$ = $1 <= $3;
	  }
	| expr ">=" expr
	  {
		$$ = $1 >= $3;
	  }
	| expr "==" expr
	  {
		$$ = $1 == $3;
	  }
	| expr "!=" expr
	  {
		$$ = $1 != $3;
	  }
	| '(' expr ')'
	  {
		$$ = $2;
	  }
	;
/*
stmt	: IF '(' expr ')' '{' prog  '}'
	  {
		if ($3)
			printf("true\n");
		else
			printf("false\n");
	  }
	| FOR '(' assig ';' expr ';' expr ')' '{' prog '}'
*/
%%

struct symtab *putsym(char *id)
{
	struct symtab *s = syms;
	while(s && strcmp(s->id, id))
		s = s->next;
	if (s)
		return s;
	s = malloc(sizeof(struct symtab));
	s->id = id;
	s->next = syms;
	s->val = 0;
	syms = s;
	return s;
}
long long int getsym(char *id)
{
	struct symtab *s = syms;
	while(s && strcmp(s->id, id))
		s = s->next;
	if(s)
		return s->val;
	else
		return 0;
}
int main(int argc, char *argv[])
{
	if ( argc > 1 )
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	return yyparse();
}
