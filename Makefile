%: %.l %.y
	bison -yd $@.y -r state
	flex $@.l
	gcc -c -lfl y.tab.c
	gcc -c -lfl lex.yy.c
# ./$@
clean:
	-rm *.o y.tab.h y.tab.c lex.yy.c *.tab.c y.output *.out
