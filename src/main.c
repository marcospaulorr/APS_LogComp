#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyparse(void);
extern FILE* yyin;

/* definidos no parser.y */
void cg_set_output(FILE* f);

int main(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "Uso: %s <arquivo.vend> [-o saida.vmasm]\n", argv[0]);
    return 1;
  }
  const char* inpath = argv[1];
  const char* outpath = "out.vmasm";

  for (int i=2; i<argc; ++i) {
    if (strcmp(argv[i], "-o")==0 && i+1<argc) {
      outpath = argv[++i];
    }
  }

  yyin = fopen(inpath, "r");
  if (!yyin) { perror("abrindo entrada"); return 1; }

  FILE* out = fopen(outpath, "w");
  if (!out) { perror("abrindo saida"); fclose(yyin); return 1; }
  cg_set_output(out);

  int rc = yyparse();
  fclose(yyin);
  fclose(out);

  if (rc == 0) {
    printf("OK: sintaxe válida. Assembly gerado em %s\n", outpath);
    return 0;
  } else {
    fprintf(stderr, "Falha: erro de análise.\n");
    return 2;
  }
}
