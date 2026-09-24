"""Parsers for the ab-fluid Lean certificate data files.

Handles the specific definition forms used in the euler-blowup certificate:
  def <name> : PieceCert := { u0 := <int>, len := <int>,
                             lo := #[[...], ...], hi := #[[...], ...],
                             cuts := [...] }
  def <name> : Array DI := #[<<a>, <b>>, ...]
  def <name> : List HCell := [<[..], [..], [..], <e0>, <e1>, <e2}>, ...]

Integers may appear parenthesized when negative: (-123).
"""

import re
from ab_fluid_di import DI, fl, cl, ONE


def _expand_di_const(text):
    """Replace (DI.const (NUM / DEN)).lo/.hi with the literal integer."""
    def rep(m):
        num, den, which = int(m.group(1)), int(m.group(2)), m.group(3)
        v = fl(num * ONE, den) if which == 'lo' else cl(num * ONE, den)
        return str(v)
    return re.sub(r'\(DI\.const \([ ]*([0-9]+) / ([0-9]+)\)\)\.(lo|hi)', rep, text)


def _tokenize(s):
    # tokens: identifiers, integers (possibly parenthesized negatives), punctuation
    tok = re.compile(r"""
        \([ ]*-[0-9]+[ ]*\)   |
        -?[0-9]+              |
        [A-Za-z_][A-Za-z0-9_']* |
        :=|\#\[|\[|\]|,|\{|\}|\(|\)|⟨|⟩|<|>
    """, re.X)
    out = []
    for m in tok.finditer(s):
        t = m.group(0)
        if t.startswith('('):
            out.append(int(t.strip('() ')))
        elif re.fullmatch(r'-?[0-9]+', t):
            out.append(int(t))
        else:
            out.append(t)
    return out


class _P:
    def __init__(self, toks):
        self.t = toks
        self.i = 0

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else None

    def next(self):
        v = self.t[self.i]
        self.i += 1
        return v

    def expect(self, v):
        got = self.next()
        assert got == v, f"expected {v!r} got {got!r}"
        return got

    def integer(self):
        v = self.next()
        assert isinstance(v, int), f"expected int got {v!r}"
        return v

    def int_list(self):
        # [ i, i, ... ]
        self.expect('[')
        out = []
        if self.peek() == ']':
            self.next()
            return out
        while True:
            out.append(self.integer())
            if self.peek() == ',':
                self.next()
                continue
            self.expect(']')
            return out

    def int_array(self):
        # #[ ... ]
        self.expect('#[')
        out = []
        if self.peek() == ']':
            self.next()
            return out
        while True:
            out.append(self.integer())
            if self.peek() == ',':
                self.next()
                continue
            self.expect(']')
            return out

    def di(self):
        # ⟨ a, b ⟩
        self.expect('⟨')
        a = self.integer()
        self.expect(',')
        b = self.integer()
        self.expect('⟩')
        return DI(a, b)

    def di_array(self):
        self.expect('#[')
        out = []
        if self.peek() == ']':
            self.next()
            return out
        while True:
            out.append(self.di())
            if self.peek() == ',':
                self.next()
                continue
            self.expect(']')
            return out


def parse_piece_cert(text):
    """Parse all `def <name> : PieceCert := {...}` in text. Returns dict name->dict."""
    out = {}
    # find each def block; PieceCert records end with '}' before the next def/theorem
    for m in re.finditer(r'def\s+(\w+)\s*:\s*PieceCert\s*:=\s*\{', text):
        name = m.group(1)
        # extract balanced braces from m.end()-1
        start = m.end() - 1
        depth = 0
        j = start
        while True:
            c = text[j]
            if c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
                if depth == 0:
                    break
            j += 1
        body = text[start:j + 1]
        p = _P(_tokenize(body))
        p.expect('{')
        rec = {}
        while p.peek() != '}':
            field = p.next()
            p.expect(':=')
            if field in ('u0', 'len'):
                rec[field] = p.integer()
            elif field in ('lo', 'hi'):
                # #[ [..], [..], .. ]  (array of int arrays)
                p.expect('#[')
                arr = []
                if p.peek() == ']':
                    p.next()
                else:
                    while True:
                        arr.append(p.int_list())
                        if p.peek() == ',':
                            p.next()
                            continue
                        p.expect(']')
                        break
                rec[field] = arr
            elif field == 'cuts':
                rec[field] = p.int_list()
            else:
                raise ValueError(f"unknown field {field}")
            if p.peek() == ',':
                p.next()
        out[name] = rec
    return out


def parse_di_array_defs(text):
    """Parse all `def <name> : Array DI := #[...]` in text. Returns dict name->list[DI]."""
    text = _expand_di_const(text)
    out = {}
    for m in re.finditer(r'def\s+(\w+)\s*:\s*Array DI\s*:=\s*#\[', text):
        name = m.group(1)
        start = m.end() - 2  # at '#['
        # find matching ']'
        depth = 0
        j = start
        while True:
            if text[j:j + 2] == '#[':
                depth += 1
                j += 2
                continue
            c = text[j]
            if c == '[':
                depth += 1
            elif c == ']':
                depth -= 1
                if depth == 0:
                    break
            j += 1
        body = text[start:j + 1]
        p = _P(_tokenize(body))
        out[name] = p.di_array()
    return out


def parse_hcell_list(text, defname):
    """Parse `def <defname> : List HCell := [...]`. Returns list of (p0,p1,p2,e0,e1,e2)."""
    m = re.search(r'def\s+' + defname + r'\s*:\s*List HCell\s*:=\s*\[', text)
    assert m, f"{defname} not found"
    start = m.end() - 1
    depth = 0
    j = start
    while True:
        c = text[j]
        if c == '[':
            depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0:
                break
        j += 1
    body = text[start:j + 1]
    p = _P(_tokenize(body))
    p.expect('[')
    out = []
    if p.peek() == ']':
        return out
    while True:
        # ⟨ p0, p1, p2, e0, e1, e2 ⟩
        p.expect('⟨')
        p0 = p.int_list(); p.expect(',')
        p1 = p.int_list(); p.expect(',')
        p2 = p.int_list(); p.expect(',')
        e0 = p.integer(); p.expect(',')
        e1 = p.integer(); p.expect(',')
        e2 = p.integer()
        p.expect('⟩')
        out.append((p0, p1, p2, e0, e1, e2))
        if p.peek() == ',':
            p.next()
            continue
        p.expect(']')
        return out
