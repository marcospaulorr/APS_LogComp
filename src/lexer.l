%option noyywrap yylineno nodefault noinput nounput

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "parser.tab.h"

  static char* duptext(const char* s) {
    size_t n = strlen(s);
    char* p = (char*)malloc(n+1);
    if (!p) { fprintf(stderr, "OOM\n"); exit(1); }
    memcpy(p, s, n+1);
    return p;
  }
%}

%%

[ \t\r]+                 { /* ignora espacos/tabs */ }
\#[^\n]*                 { /* ignora comentario de linha */ }
\n                       { /* conta linha */ }

"inserir"                { return INSERIR; }
"selecionar"             { return SELECIONAR; }
"vender"                 { return VENDER; }
"troco"                  { return TROCO; }
"print"                  { return PRINT; }

"set"                    { return SET; }
"credito"                { return CREDITO; }
"selecao"                { return SELECAO; }

"se"                     { return SE; }
"senao"                  { return SENAO; }
"enquanto"               { return ENQUANTO; }
"sempre"                 { return SEMPRE; }
"ha_eventos"             { return HA_EVENTOS; }

"ha_credito"             { return HA_CREDITO; }
"selecao_valida"         { return SELECAO_VALIDA; }
"tem_estoque"            { return TEM_ESTOQUE; }
"preco_coberto"          { return PRECO_COBERTO; }

"e"                      { return E; }
"ou"                     { return OU; }

[0-9]+"c"                { yylval.ival = atoi(yytext); return VALOR; }
"P"[0-9]+                { yylval.sval = duptext(yytext); return PRODUTO; }

\"([^\\\"\n]|\\[\\\"nt])*\"   { yylval.sval = duptext(yytext); return STRING; }

";"                      { return SEMI; }
":"                      { return COLON; }
"{"                      { return LBRACE; }
"}"                      { return RBRACE; }
"="                      { return EQ; }

.                        {
                           fprintf(stderr, "[lexer] caractere invalido '%s' na linha %d\n", yytext, yylineno);
                           return INVALID;
                         }

%%

/* (opcional) código do usuário aqui */
