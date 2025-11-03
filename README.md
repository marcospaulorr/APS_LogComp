ótimo! abaixo vai um README enxuto, mas completo e “à prova de banca”. é só colar no `README.md` do repositório.

---

# APS_LogComp — VendingMachineVM

Projeto de uma **linguagem simples** para controlar uma máquina de vendas (vending machine), com **variáveis**, **condicionais** e **laços**, cujo *frontend* (Flex/Bison) gera um **assembly** minimalista consumido por um **emulador** (VM) incluso no repositório.

> **Objetivo de avaliação**: cumprir a rubrica até conceito **B**:
> (1) EBNF, (2) Análise Léxica (Flex), (3) Análise Sintática (Bison), (4) Geração de “assembly” para uma VM e exemplos executáveis.

---

## Sumário

* [Arquitetura](#arquitetura)
* [EBNF da linguagem](#ebnf-da-linguagem)
* [Como montar o projeto](#como-montar-o-projeto)
* [Como usar (compilar e rodar)](#como-usar-compilar-e-rodar)
* [Exemplos prontos](#exemplos-prontos)
* [Referência rápida da linguagem](#referência-rápida-da-linguagem)
* [Formato dos literais](#formato-dos-literais)
* [Estrutura de diretórios](#estrutura-de-diretórios)
* [Mensagens de erro e *troubleshooting*](#mensagens-de-erro-e-troubleshooting)
* [Notas de implementação / decisões de design](#notas-de-implementação--decisões-de-design)

---

## Arquitetura

* **Frontend (Flex/Bison)**:

  * `src/lexer.l` (tokens)
  * `src/parser.y` (gramática + geração de assembly simples)
* **“Assembly” da VM** (saída do parser): arquivo `.vmasm` textual.
* **VM**: `vm/vm_emulator.py` interpreta o `.vmasm` e simula:

  * **registradores** lógicos: `CREDITO`, `SELECAO`
  * **sensores** (read-only): `ha_credito`, `selecao_valida`, `tem_estoque P*`, `preco_coberto P*`
  * **ações**: `INSERT`, `SELECT`, `VEND`, `CHANGE`, `PRINT*`

---

## EBNF da linguagem

```ebnf
programa       = { declaracao } EOF ;

declaracao     = acao ";"
               | if_stmt
               | while_stmt
               | comentario ;

acao           = "inserir"   valor
               | "selecionar" produto
               | "vender"
               | "troco"
               | "print" saida
               | "set" "credito" "=" valor
               | "set" "selecao" "=" produto ;

saida          = string | "credito" | "selecao" ;

if_stmt        = "se" cond ":" bloco [ "senao" ":" bloco ] ;

while_stmt     = "enquanto" loop_cond ":" bloco ;

bloco          = "{" { declaracao } "}" ;

cond           = pred { ( "e" | "ou" ) pred } ;
pred           = "ha_credito"
               | "selecao_valida"
               | "tem_estoque" produto
               | "preco_coberto" produto ;

loop_cond      = "sempre" | "ha_eventos" ;

comentario     = "#" { caractere_nao_quebra_linha } ( "\n" | EOF ) ;
```

---

## Como montar o projeto

**Requisitos (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install -y build-essential flex bison python3
```

**Build:**

```bash
# na raiz do repositório
make
```

> Se estiver vindo de outro SO/editor, normalize finais de linha:

```bash
dos2unix src/lexer.l src/parser.y || true
```

---

## Como usar (compilar e rodar)

1. **Gerar assembly** a partir do código-fonte da linguagem:

```bash
./vendc examples/demo_ok.vend -o out.vmasm
```

Saída esperada:

```
OK: sintaxe válida. Assembly gerado em out.vmasm
```

2. **Rodar no emulador da VM** (defina preços/estoques via flags):

```bash
python3 vm/vm_emulator.py out.vmasm --price P1:75 --stock P1:2
```

Exemplo de execução real:

```
iniciando venda
VEND OK P1 credito=225
225
nao foi possivel vender
TROCO 225
loop
```

**Flags úteis da VM:**

* `--price P<id>:<centavos>` ex.: `--price P1:75`
* `--stock P<id>:<qtd>` ex.: `--stock P1:2`

---

## Exemplos prontos

* `examples/demo_ok.vend` — programa canônico:

```plain
set credito = 200c;
set selecao = P0;

inserir 100c;
selecionar P1;

se ha_credito e selecao_valida e tem_estoque P1 e preco_coberto P1: {
  print "iniciando venda";
  vender;
  print credito;
} senao: {
  print "nao foi possivel vender";
  troco;
}

enquanto sempre: {
  print "loop";
}
```

* `examples/if_else.vend` — condicional simples:

```plain
set selecao = P1;
set credito = 100c;

se ha_credito e selecao_valida: {
  print "ok";
  vender;
} senao: {
  print "nope";
  troco;
}
```

* `examples/while.vend` — laço simples:

```plain
enquanto sempre: {
  print "loop";
  troco;
}
```

**Como testar rapidamente:**

```bash
./vendc examples/if_else.vend -o out_if.vmasm && \
python3 vm/vm_emulator.py out_if.vmasm --price P1:75 --stock P1:2

./vendc examples/while.vend -o out_while.vmasm && \
python3 vm/vm_emulator.py out_while.vmasm --price P1:75 --stock P1:2
```

---

## Referência rápida da linguagem

**Ações (terminam com `;`):**

* `inserir <valor>` — adiciona crédito (centavos)
* `selecionar <produto>` — escolhe um produto (`P0`, `P1`, …)
* `vender` — tenta efetuar venda
* `troco` — devolve crédito remanescente
* `print <saida>` — imprime `string`, `credito` ou `selecao`
* `set credito = <valor>` — define diretamente o crédito
* `set selecao = <produto>` — define diretamente a seleção

**Condicionais:**

```plain
se <cond> : { ... } senao : { ... }
```

onde `cond` é uma sequência de `pred` com `e`/`ou`:

```
ha_credito | selecao_valida | tem_estoque Pn | preco_coberto Pn
```

**Laços:**

```
enquanto sempre : { ... }
enquanto ha_eventos : { ... }   # placeholder (semântica mínima)
```

**Comentários**: começam com `#` até o fim da linha.

---

## Formato dos literais

* **Valor em centavos**: `<numero>c`
  Exemplos: `0c`, `75c`, `200c`
* **Produto**: `P<numero>`
  Exemplos: `P0`, `P1`, `P2`
* **String** (aspas duplas, com escapes `\n`, `\t`, `\"`, `\\`):
  Ex.: `"iniciando venda"`

---

## Estrutura de diretórios

```
.
├── src/
│   ├── lexer.l         # Flex
│   ├── parser.y        # Bison (+ geração de assembly simples)
│   ├── main.c          # CLI vendc
│   └── codegen.h       # helper de geração textual
├── vm/
│   └── vm_emulator.py  # interpretador do .vmasm
├── examples/
│   ├── demo_ok.vend
│   ├── if_else.vend
│   └── while.vend
├── Makefile
└── README.md
```

---

## Mensagens de erro e *troubleshooting*

* `unrecognized rule (Flex)`: normalmente arquivo `lexer.l` corrompido (resquícios de here-doc).
  Solução: garantir **duas** linhas `%%` e nenhum `EOF` perdido no meio do arquivo; rodar `dos2unix`.
* `erro sintático na linha N (Bison)`: conferir sintaxe do `.vend` (pontos e vírgulas, chaves, `:` após `se`/`enquanto`).
* `FileNotFoundError: out.vmasm`: faltou gerar o assembly (`./vendc ... -o out.vmasm`) antes de chamar a VM.

---

## Notas de implementação / decisões de design

* **Escopo**: projeto focado em **frontend** (lexer+parser) e **geração textual** para uma VM simples.
* **Semântica mínima**: a VM é responsável por validar preço, estoque, etc.; o parser apenas **traduz comandos**.
* **Condições**: suporte a expressão booleana na forma `pred { (e|ou) pred }` (sem precedência diferenciada — avaliação *left-associative*).
* **Portabilidade**: código testado em Ubuntu (Flex, Bison, GCC e Python 3).
* **Objetivo pedagógico**: demonstrar pipeline clássico *linguagem → assembly → VM* com implementação concisa.

---

