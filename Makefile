LEX=flex
CC=gcc
CXX=g++
YACC=bison
YFLAGS=-d -r state
CFLAGS+=-Wall -Wno-unused
CXXFLAGS+=-Wall -Wno-unused
LDFLAGS+=-Wl,--no-as-needed -lm # -lfl
DIFF=diff
DIFFFLAGS=--ignore-case --ignore-all-space --ignore-blank-lines  -up

APP=compiler

all: $(APP)_app
$(APP)_app: $(APP).lex.o $(APP).tab.o
	@ echo "    LD    $(APP)"
	@ [ -e $(APP).tab.o ] \
		&& $(CC) -o $@ $^ $(LDFLAGS) \
		|| $(CC) -o $@ $< $(LDFLAGS)

run: $(APP)_app
	@ echo "    RUN   $(APP)"
	@ ./$<

%.lex.c: %.l
	@ echo "    FLEX  $<"
	@ $(LEX) $(LFLAGS) --outfile=$(APP).lex.c $<
%.tab.c %.tab.h: %.y
	@ echo "    BISON $<"
	@ $(YACC) $(YFLAGS) $<

%.tab.o: %.tab.c
	@ echo "    CC    $<"
	@ [ -e "$(APP).y" ] \
		&& $(CC) $(CFLAGS) -c $< \
		|| true
%.lex.o: %.lex.c %.tab.h
	@ echo "    CC    $<"
	@ $(CC) $(CFLAGS) -c $<

# Fallback when we still have no bison file for the app
%.tab.c %.tab.h %.tab.o::
	@ echo -e "\033[41m# IGNORING DEPENCEDY: $@\033[0m" 1>&2

TESTS:= $(sort $(wildcard tests/$(APP)-[0-9]*.in))
TESTS:=$(TESTS:.in=.in.c)
test: $(TESTS)
tests/%.in.c: $(APP)_app
	@ echo -ne "\033[34m"
	@ echo "##############################################################"
	@ echo "# TEST: $@"
	@ echo "##############################################################"
	@ echo -ne "\033[0m"
	@ ./$< $(@:.c=)
	@ [ ! -e "$(@:.in.c=.out)" ] \
		|| (./$< $(@:.c=) 2>/dev/null | $(DIFF) $(DIFFFLAGS) $(@:.in.c=.out) - )

# compile llvm-c based app
llvm-c: $(APP).c
	$(CXX) $< -o $(APP) $(shell llvm-config --cflags --libs core) \
		-ldl -lcurses -lpthread $(CXXFLAGS) $(LDFLAGS)
# compile llvm based app
llvm: $(APP).cpp
	$(CXX) $< -o $(APP) $(shell llvm-config --cxxflags --libs core) \
		-ldl -lcurses -lpthread $(CXXFLAGS) $(LDFLAGS)

.NOTPARALLEL: clean test
.PHONY: clean
clean:
	@ echo "    CLEAN"
	@ -$(RM) *.o $(APP).tab.* $(APP).lex.* $(APP).dot $(APP).output \
		$(APP)_app lex.backup # y.tab.* lex.yy.* y.output
