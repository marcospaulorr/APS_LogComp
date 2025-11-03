#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdio.h>
#include <stdarg.h>

static FILE* CODE_OUT = NULL;
static int   LABEL_SEQ = 0;

static void cg_set_out(FILE* f) { CODE_OUT = f; }
static int  cg_label()          { return LABEL_SEQ++; }

static void cg(const char* fmt, ...) {
  if (!CODE_OUT) return;
  va_list ap; va_start(ap, fmt);
  vfprintf(CODE_OUT, fmt, ap);
  va_end(ap);
}

#endif
