%{
  #include <stdio.h>
  #include <stdlib.h>

  int yylex(void);
  void yyerror(const char* s);
%}

%union {
  int   ival;   /* VALOR (centavos) */
  char* sval;   /* STRING e PRODUTO */
}

/* Tokens */
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
  | programa declaracao
  ;

declaracao
  : acao SEMI
  | if_stmt
  | while_stmt
  ;

acao
  : INSERIR VALOR
  | SELECIONAR PRODUTO
  | VENDER
  | TROCO
  | PRINT saida
  | SET CREDITO EQ VALOR
  | SET SELECAO EQ PRODUTO
  ;

saida
  : STRING
  | CREDITO
  | SELECAO
  ;

if_stmt
  : SE cond COLON bloco
  | SE cond COLON bloco SENAO COLON bloco
  ;

while_stmt
  : ENQUANTO loop_cond COLON bloco
  ;

bloco
  : LBRACE RBRACE
  | LBRACE bloco_conteudo RBRACE
  ;

bloco_conteudo
  : declaracao
  | bloco_conteudo declaracao
  ;

cond
  : pred
  | cond E  pred
  | cond OU pred
  ;

pred
  : HA_CREDITO
  | SELECAO_VALIDA
  | TEM_ESTOQUE PRODUTO
  | PRECO_COBERTO PRODUTO
  ;

loop_cond
  : SEMPRE
  | HA_EVENTOS
  ;

%%

void yyerror(const char* s) {
  extern int yylineno;
  fprintf(stderr, "[parser] erro sintático na linha %d: %s\n", yylineno, s);
}
