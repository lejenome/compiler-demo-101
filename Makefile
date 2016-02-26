LEX=flex
CC=gcc
YACC=bison
YFLAGS= -d -r state

APP=compiler

$(APP): $(APP).tab.o $(APP).lex.o
	$(CC) $(LDFLAGS) -lfl -o $@ $^

%.lex.c: %.l
	$(LEX) $<
%.tab.c %.tab.h: %.y
	$(YACC) $(YFLAGS) $<

%.tab.o: %.tab.c
	$(CC) $(CFLAGS) -c $<
%.lex.o: %.lex.c %.tab.h
	$(CC) $(CFLAGS) -c $<
# ./$@
clean:
	-$(RM) *.o $(APP).tab.* $(APP).lex.* $(APP).dot $(APP).output $(APP) \
		lex.backup # y.tab.* lex.yy.* y.output
