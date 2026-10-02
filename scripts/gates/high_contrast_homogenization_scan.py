import re, pathlib, sys
R = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else '/home/hatch/workspace/audit-hch/HighContrastHomogenization')
files = sorted(R.rglob('*.lean'))
n_files = len(files)
sorry_hits, admit_hits, axiom_hits, sorryax = [], [], [], []
comment_sorry = []
for f in files:
    txt = f.read_text(errors='replace')
    lines = txt.split('\n')
    in_block = False
    for i, ln in enumerate(lines, 1):
        code = ln
        # crude comment stripping: track /- -/ blocks and -- line comments
        out = []
        j = 0
        while j < len(code):
            if in_block:
                k = code.find('-/', j)
                if k == -1: j = len(code); break
                else: j = k + 2; in_block = False
            else:
                k1 = code.find('/-', j); k2 = code.find('--', j)
                if k1 != -1 and (k2 == -1 or k1 < k2):
                    out.append(code[j:k1]); j = k1 + 2; in_block = True
                elif k2 != -1:
                    out.append(code[j:k2]); break
                else:
                    out.append(code[j:]); break
        stripped = ''.join(out)
        rel = str(f.relative_to(R))
        if re.search(r'\bsorry\b', stripped): sorry_hits.append(f'{rel}:{i}')
        elif re.search(r'\bsorry\b', ln): comment_sorry.append(f'{rel}:{i}')
        if re.search(r'\badmit(ted)?\b', stripped): admit_hits.append(f'{rel}:{i}')
        if re.match(r'\s*axiom\b', stripped): axiom_hits.append(f'{rel}:{i}: {ln.strip()[:90]}')
        if 'sorryAx' in stripped: sorryax.append(f'{rel}:{i}')
print('files:', n_files)
print('CODE sorry hits:', len(sorry_hits))
for h in sorry_hits: print('  SORRY', h)
print('comment-only sorry:', len(comment_sorry))
print('admit hits:', len(admit_hits))
for h in admit_hits: print('  ADMIT', h)
print('axiom declarations:', len(axiom_hits))
for h in axiom_hits: print('  AXIOM', h)
print('sorryAx:', len(sorryax))
