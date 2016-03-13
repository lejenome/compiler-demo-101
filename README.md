Get Started on Compilers Demo
=============================

Tools to be used:
- Flex (LEX alternative) to generate a scanner using Deterministic Finit
  Automata and Regular Expressions
- Bison (Yacc compatible alternative) to generate a parser using a grammar
- LLVM ...

Install on Ubuntu 14.04:
```sh
sudo apt-get install flex flex-doc bison bison-doc make-doc llvm-dev libncurses5-dev git gcc g++ clang
```

To run `calc` example:
```sh
make APP=calc run
```
