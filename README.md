# APS_LogComp

## VendingMachineVM

- O que é?

Projeto de uma linguagem para controlar uma máquina de vendas (usei como exemplo as do Insper), com variáveis, condicionais e laços.

### EBNF

programa       = { declaracao } EOF ;

declaracao     = acao ";"
               | if_stmt
               | while_stmt
               | comentario
               ;

acao           = "inserir"   valor
               | "selecionar" produto
               | "vender"
               | "troco"
               | "print" saida
               | "set" "credito" "=" valor
               | "set" "selecao" "=" produto
               ;

saida          = string | "credito" | "selecao" ;

if_stmt        = "se" cond ":" bloco [ "senao" ":" bloco ] ;

while_stmt     = "enquanto" loop_cond ":" bloco ;

bloco          = "{" { declaracao } "}" ;

cond           = pred { ( "e" | "ou" ) pred } ;
pred           = "ha_credito"
               | "selecao_valida"
               | "tem_estoque" produto
               | "preco_coberto" produto
               ;

loop_cond      = "sempre" | "ha_eventos" ;

comentario     = "#" { caractere_nao_quebra_linha } ( "\n" | EOF ) ;