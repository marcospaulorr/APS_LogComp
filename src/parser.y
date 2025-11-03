%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "codegen.h"

  int yylex(void);
  void yyerror(const char* s);

  /* API chamada por main.c */
  void cg_set_output(FILE* f) { cg_set_out(f); }
%}

%union {
  int   ival;   /* VALOR (centavos) */
  char* sval;   /* STRING e PRODUTO */
}

/* Tokens (mesmos do seu lexer.l) */
%token INSERIR SELECIONAR VENDER TROCO PRINT
%token SET CREDITO SELECAO
%token SE SENAO ENQUANTO SEMPRE HA_EVENTOS
%token HA_CREDITO SELECAO_VALIDA TEM_ESTOQUE PRECO_COBERTO
%token E OU
%token <ival> VALOR
%token <sval> PRODUTO
%token <sval> STRING
%token LBRACE RBRACE COLON SEMI EQ
%token INVALID

%%

programa
  : %empty
    {
      cg("; VendingMachineVM assembly\n");
      cg("START:\n");
    }
  | programa declaracao
  ;

declaracao
  : acao SEMI
  | if_stmt
  | while_stmt
  ;

acao
  : INSERIR VALOR            { cg("    INSERT %d\n", $2); }
  | SELECIONAR PRODUTO       { cg("    SELECT %s\n", $2); free($2); }
  | VENDER                   { cg("    VEND\n"); }
  | TROCO                    { cg("    CHANGE\n"); }
  | PRINT saida
  | SET CREDITO EQ VALOR     { cg("    SETCRED %d\n", $4); }
  | SET SELECAO EQ PRODUTO   { cg("    SETSEL %s\n", $4); free($4); }
  ;

saida
  : STRING                   { cg("    PRINTSTR %s\n", $1); free($1); }
  | CREDITO                  { cg("    PRINTCRED\n"); }
  | SELECAO                  { cg("    PRINTSEL\n"); }
  ;

if_stmt
  : SE cond COLON bloco
    { cg("    ; [IF] fim do bloco THEN\n"); }
  | SE cond COLON bloco SENAO COLON bloco
    { cg("    ; [IF/ELSE] fim dos blocos THEN/ELSE\n"); }
  ;

while_stmt
  : ENQUANTO SEMPRE COLON bloco
    { cg("    ; [WHILE SEMPRE] (versão mínima – sem saltos)\n"); }
  | ENQUANTO HA_EVENTOS COLON bloco
    { cg("    ; [WHILE HA_EVENTOS] (versão mínima – sem saltos)\n"); }
  ;

bloco
  : LBRACE RBRACE
    { cg("    ; { }\n"); }
  | LBRACE bloco_conteudo RBRACE
    { cg("    ; fim bloco\n"); }
  ;

bloco_conteudo
  : declaracao
  | bloco_conteudo declaracao
  ;

/* cond = pred { (E|OU) pred } */
cond
  : pred cond_tail
  ;

cond_tail
  : %empty
  | E  pred cond_tail
  | OU pred cond_tail
  ;

pred
  : HA_CREDITO
  | SELECAO_VALIDA
  | TEM_ESTOQUE PRODUTO     { free($2); }
  | PRECO_COBERTO PRODUTO   { free($2); }
  ;

%%

void yyerror(const char* s) {
  extern int yylineno;
  fprintf(stderr, "[parser] erro sintático na linha %d: %s\n", yylineno, s);
}
