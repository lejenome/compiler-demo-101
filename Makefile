LEX=flex
CC=gcc
YACC=bison
YFLAGS=-d -r state
CFLAGS+=-Wall
LDFLAGS+=-Wl,--no-as-needed -lfl -lm
DIFF=diff
DIFFFLAGS=--ignore-case --ignore-all-space --ignore-blank-lines  -up

APP=compiler

all: $(APP)
$(APP): $(APP).lex.o $(APP).tab.o
	[ -e $(APP).tab.o ] \
		&& $(CC) $(LDFLAGS) -o $@ $^ \
		|| $(CC) $(LDFLAGS) -o $@ $<

run: $(APP)
	./$(APP)

%.lex.c: %.l
	$(LEX) $(LFLAGS) --outfile=$(APP).lex.c $<
%.tab.c %.tab.h: %.y
	$(YACC) $(YFLAGS) $<

%.tab.o: %.tab.c
	$(CC) $(CFLAGS) -c $<
%.lex.o: %.lex.c %.tab.h
	$(CC) $(CFLAGS) -c $<

# Fallback when we still have no bison file for the app
%.tab.c %.tab.h %.tab.o::
	@ echo -e "\033[41m# IGNORING DEPENCEDY: $@\033[0m" 1>&2

TESTS:= $(sort $(wildcard tests/*.in))
TESTS:=$(TESTS:.in=.in.c)
test: $(TESTS)
tests/%.in.c: $(APP)
	@ echo -ne "\033[34m"
	@ echo "##############################################################"
	@ echo "# TEST: $@"
	@ echo "##############################################################"
	@ echo -ne "\033[0m"
	@ ./$(APP) $(@:.c=)
	@ [ ! -e "$(@:.in.c=.out)" ] \
		|| (./$(APP) $(@:.c=) 2>/dev/null | $(DIFF) $(DIFFFLAGS) $(@:.in.c=.out) - )

.NOTPARALLEL: clean test
.PHONY: clean
clean:
	-$(RM) *.o $(APP).tab.* $(APP).lex.* $(APP).dot $(APP).output $(APP) \
		lex.backup # y.tab.* lex.yy.* y.output
