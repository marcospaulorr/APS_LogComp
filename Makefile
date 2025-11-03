CC=gcc
CFLAGS=-O2 -Wall -Wextra
LEX=flex
YACC=bison

all: vendc

vendc: src/parser.tab.c src/lexer.yy.c src/main.c src/codegen.h
	$(CC) $(CFLAGS) src/parser.tab.c src/lexer.yy.c src/main.c -o vendc

src/parser.tab.c src/parser.tab.h: src/parser.y src/codegen.h
	$(YACC) -d -Wall -Wcounterexamples -o src/parser.tab.c src/parser.y

src/lexer.yy.c: src/lexer.l src/parser.tab.h
	$(LEX) -o src/lexer.yy.c src/lexer.l

test: vendc
	./vendc examples/demo_ok.vend -o out.vmasm

run: test
	python3 vm/vm_emulator.py out.vmasm --price P1:75,P2:100 --stock P1:2,P2:1

clean:
	rm -f vendc vend-parse src/parser.tab.c src/parser.tab.h src/lexer.yy.c out.vmasm
