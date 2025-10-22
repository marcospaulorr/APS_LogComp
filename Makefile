CC=gcc
CFLAGS=-O2 -Wall -Wextra
LEX=flex
YACC=bison

all: vend-parse

vend-parse: src/parser.tab.c src/lexer.yy.c src/main.c
	$(CC) $(CFLAGS) src/parser.tab.c src/lexer.yy.c src/main.c -o vend-parse

src/parser.tab.c src/parser.tab.h: src/parser.y
	$(YACC) -d -Wall -Wcounterexamples -o src/parser.tab.c src/parser.y

src/lexer.yy.c: src/lexer.l src/parser.tab.h
	$(LEX) -o src/lexer.yy.c src/lexer.l

test: vend-parse
	./vend-parse examples/demo_ok.vend

clean:
	rm -f vend-parse src/parser.tab.c src/parser.tab.h src/lexer.yy.c
