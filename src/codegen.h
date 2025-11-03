#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdio.h>
#include <stdarg.h>

/* Destino do código gerado (definido pelo main) */
static FILE* CODE_OUT = NULL;

/* Definido pelo main.c */
static void cg_set_out(FILE* f) { CODE_OUT = f; }

/* Emissor simples de linhas de assembly */
static void cg(const char* fmt, ...) {
  if (!CODE_OUT) return;
  va_list ap;
  va_start(ap, fmt);
  vfprintf(CODE_OUT, fmt, ap);
  va_end(ap);
}

#endif

