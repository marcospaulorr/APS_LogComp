#!/usr/bin/env python3
import sys, math, re

class VM:
    def __init__(self):
        self.labels = {}
        self.prog = []
        self.pc = 0
        self.R = {'R0':0, 'R1':0}
        self.stack = []
        # Estado da vending
        self.credito = 0
        self.selecao = "P0"
        self.preco = {}
        self.estoque = {}
        self.event_queue = 0  # simplificado

    # -------- sensores --------
    def sensor(self, name, arg=None):
        if name == 'HA_CREDITO':
            return 1 if self.credito > 0 else 0
        if name == 'SELECAO_VALIDA':
            return 1 if self.selecao != "P0" else 0
        if name == 'HA_EVENTOS':
            return 1 if self.event_queue > 0 else 0
        if name == 'TEM_ESTOQUE':
            return 1 if self.estoque.get(arg,0) > 0 else 0
        if name == 'PRECO_COBERTO':
            p = self.preco.get(arg, None)
            return 1 if (p is not None and self.credito >= p) else 0
        raise RuntimeError(f"Sensor desconhecido: {name} {arg or ''}")

    # -------- parsing --------
    def load(self, path):
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        # primeira passada: labels
        for i,raw in enumerate(lines):
            line = raw.split(';')[0].strip()
            if not line: continue
            if line.endswith(':'):
                lab = line[:-1].strip()
                self.labels[lab] = len(self.prog)
            else:
                self.prog.append(line)
        # segunda passada: resolvemos depois no run()

    # -------- execução --------
    def run(self, max_steps=100000):
        steps = 0
        while self.pc < len(self.prog):
            steps += 1
            if steps > max_steps:
                raise RuntimeError("Loop muito longo (proteção)")
            inst = self.prog[self.pc]
            self.pc += 1
            self.exec_inst(inst)

    def goto(self, label):
        if label not in self.labels:
            raise RuntimeError(f"Label desconhecido: {label}")
        self.pc = self.labels[label]

    def exec_inst(self, inst):
        tok = inst.strip().split()
        if not tok: return
        op = tok[0].upper()

        # --- Minsky básico ---
        if op == 'SETREG':      # SETREG R0 5
            self.R[tok[1]] = int(tok[2]); return
        if op == 'INC':         # INC R0
            self.R[tok[1]] += 1; return
        if op == 'DECJZ':       # DECJZ R0 Lx
            r = tok[1]; self.R[r] -= 1
            if self.R[r] == 0: self.goto(tok[2]); return
            return
        if op == 'GOTO':        # GOTO Lx
            self.goto(tok[1]); return
        if op == 'PUSH':        # PUSH R0
            self.stack.append(self.R[tok[1]]); return
        if op == 'POP':         # POP R0
            self.R[tok[1]] = self.stack.pop() if self.stack else 0; return

        # --- Domínio vending ---
        if op == 'INSERT':
            self.credito += int(tok[1]); return
        if op == 'SELECT':
            self.selecao = tok[1]; return
        if op == 'SETCRED':
            self.credito = int(tok[1]); return
        if op == 'SETSEL':
            self.selecao = tok[1]; return
        if op == 'VEND':
            p = self.preco.get(self.selecao, None)
            if p is not None and self.credito >= p and self.estoque.get(self.selecao,0)>0:
                self.credito -= p
                self.estoque[self.selecao] -= 1
                print(f"VEND OK {self.selecao} credito={self.credito}")
            else:
                print("VEND FAIL")
            return
        if op == 'CHANGE':
            print(f"TROCO {self.credito}")
            self.credito = 0; return
        if op == 'PRINTCRED':
            print(self.credito); return
        if op == 'PRINTSEL':
            print(self.selecao); return
        if op == 'PRINTSTR':
            # junta o resto e tira aspas
            s = inst.split('PRINTSTR',1)[1].strip()
            print(eval(s))  # usa literal Python (aspas já no assembly)
            return

        # --- Sensores p/ saltos ---
        if op == 'SENSORJZ':     # SENSORJZ HA_CREDITO Lfalse
            name = tok[1]; arg = tok[2] if name in ('TEM_ESTOQUE','PRECO_COBERTO') and len(tok)>3 else None
            lab  = tok[-1]
            val = self.sensor(name, arg)
            if val == 0: self.goto(lab)
            return
        if op == 'SENSORJNZ':    # SENSORJNZ HA_EVENTOS Ltrue
            name = tok[1]; arg = tok[2] if name in ('TEM_ESTOQUE','PRECO_COBERTO') and len(tok)>3 else None
            lab  = tok[-1]
            val = self.sensor(name, arg)
            if val != 0: self.goto(lab)
            return

        # --- Config (fora do código gerado) ---
        if op == 'SETPRICE':     # SETPRICE P1 75
            self.preco[tok[1]] = int(tok[2]); return
        if op == 'SETSTOCK':     # SETSTOCK P1 2
            self.estoque[tok[1]] = int(tok[2]); return

        raise RuntimeError(f"Instrução desconhecida: {inst}")

def main():
    if len(sys.argv) < 2:
        print("Uso: vm_emulator.py <arquivo.vmasm> [--price P1:75,P2:100] [--stock P1:2,P2:1]")
        sys.exit(1)
    path = sys.argv[1]
    vm = VM()

    # parse flags simples
    for i,a in enumerate(sys.argv[2:], start=2):
        if a == '--price' and i+1 < len(sys.argv):
            for p in sys.argv[i+1].split(','):
                k,v = p.split(':'); vm.preco[k]=int(v)
        if a == '--stock' and i+1 < len(sys.argv):
            for p in sys.argv[i+1].split(','):
                k,v = p.split(':'); vm.estoque[k]=int(v)

    vm.load(path)
    vm.run()

if __name__ == "__main__":
    main()
