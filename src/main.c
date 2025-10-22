#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE* yyin;

int main(int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "Uso: %s <arquivo.vend>\n", argv[0]);
    return 1;
  }
  yyin = fopen(argv[1], "r");
  if (!yyin) {
    perror("Erro abrindo arquivo");
    return 1;
  }
  int rc = yyparse();
  fclose(yyin);
  if (rc == 0) {
    printf("OK: sintaxe válida.\n");
    return 0;
  } else {
    fprintf(stderr, "Falha: erro de análise.\n");
    return 2;
  }
}
