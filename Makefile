LEX=flex
CC=gcc
YACC=bison -y
YFLAGS= -d -r state

APP=compiler

compiler: y.tab.o lex.yy.o
	$(CC) $(LDFLAGS) -lfl -o $@ $^

lex.yy.c: compiler.l
	$(LEX) $<
y.tab.c: compiler.y
	$(YACC) $(YFLAGS) $<

y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c $<
lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c $<
# ./$@
clean:
	-$(RM) *.o y.tab.h y.tab.c lex.yy.c *.tab.c y.output *.out
