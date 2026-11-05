#!/usr/bin/env python3
"""Independent exact verifier for the explicit nine-dimensional example.

Run: python3 verify_example.py
Python >=3.10, standard library only. No solver, randomness, or cutoff.
All checks stay active under python -O. See the paper for the proof reducing
ALL spectra to products Q x F_2^3; the program checks every hypothesis of
that reduction and exhausts the resulting finite problem.
"""
from collections import Counter
from fractions import Fraction
from itertools import combinations
from pathlib import Path
import hashlib
import json
import time

ROOT = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def span(basis):
    answer = {0}
    for b in basis:
        answer |= {x ^ b for x in answer}
    return answer


def sums(A, B=None):
    if B is None:
        B = A
    return {a ^ b for a in A for b in B}


def parity(x):
    return x.bit_count() & 1


def checked_set(points, cardinality, dimension, label):
    require(len(points) == len(set(points)) == cardinality, label + ': size/distinctness')
    require(all(type(x) is int and 0 <= x < 1 << dimension for x in points), label + ': coordinates')
    return set(points)


def walsh(points, dimension):
    # Unnormalized integer Walsh transform of the indicator.
    values = [int(x in points) for x in range(1 << dimension)]
    step = 1
    while step < len(values):
        for start in range(0, len(values), 2 * step):
            for j in range(start, start + step):
                a, b = values[j], values[j + step]
                values[j], values[j + step] = a + b, a - b
        step *= 2
    return values


def tiling(E, T):
    counts = [0] * 512
    for e in E:
        for t in T:
            counts[e ^ t] += 1
    require(counts == [1] * 512, 'Unique tiling representations')


def gram(E, spectrum):
    # A column of signs is encoded by a 64-bit integer, with 1 for -1.
    # For columns a,b, their exact integer inner product is
    # 64 - 2*popcount(a XOR b). Each diagonal entry is exactly 64.
    checked_set(spectrum, 64, 9, 'Spectrum')
    columns = [sum(parity(e & u) << i for i, e in enumerate(E)) for u in spectrum]
    require(all(64 - 2 * (a ^ b).bit_count() == 0
                for a, b in combinations(columns, 2)), 'H^T H != 64 I')


def normalized_cliques(safe, size):
    # All size-point sets containing 0 whose nonzero differences lie in safe.
    # Increasing-order recursion visits every possibility once, with only
    # adjacency and insufficient-cardinality pruning. There is no cutoff.
    adjacency = {a: {b for b in safe if b != a and (a ^ b) in safe} for a in safe}
    answer = []
    nodes = 0

    def visit(chosen, candidates):
        nonlocal nodes
        nodes += 1
        if len(chosen) == size:
            answer.append(tuple(chosen))
            return
        while candidates:
            if len(chosen) + len(candidates) < size:
                return
            a = min(candidates)
            candidates.remove(a)
            visit(chosen + [a], candidates & adjacency[a])

    visit([0], set(safe))
    return answer, nodes


def rref_three_spaces(dimension):
    # Columns are ordered from bit 0 upwards. Every 3-space has exactly one
    # reduced row echelon basis. For pivots p0<p1<p2, only nonpivot columns
    # strictly to the right of a row's pivot can be free.
    for pivots in combinations(range(dimension), 3):
        free = [(i, j) for i, p in enumerate(pivots)
                for j in range(p + 1, dimension) if j not in pivots]
        rows = [1 << p for p in pivots]
        # Gray order toggles one free entry at a time; every binary choice
        # occurs once. Trailing-bit count identifies that entry.
        for index in range(1 << len(free)):
            if index:
                bit = (index & -index).bit_length() - 1
                i, j = free[bit]
                rows[i] ^= 1 << j
            yield pivots, tuple(rows)


def main():
    started = time.perf_counter()
    source = ROOT / 'example.json'
    data = json.loads(source.read_text())
    E = checked_set(data['E'], 64, 9, 'E')
    C = checked_set(data['C'], 8, 6, 'C')
    T = checked_set(data['T'], 8, 9, 'T')
    L = checked_set(data['Lambda'], 64, 9, 'Lambda')
    require(C == {0, 1, 2, 4, 8, 16, 32, 63}, 'Displayed circuit')
    require(T == C, 'Displayed complement')
    require(L == {c + 64 * y for c in C for y in range(8)}, 'Displayed spectrum')
    spaces = [span(b) for b in data['distinct_layer_bases']]
    require(len(spaces) == 6 and all(len(B) == 8 for B in spaces), 'Six independent bases')
    assignment = data['layer_assignment']
    require(assignment == [0, 1, 2, 3, 4, 5, 0, 3], 'Layer assignment')
    layers = [spaces[i] for i in assignment]
    require(data['layer_bases'] == [data['distinct_layer_bases'][i] for i in assignment], 'Expanded bases')
    require(E == {x + 64 * y for y, B in enumerate(layers) for x in B}, 'Domain reconstruction')
    S = sums(C)
    Z = {x for x in range(64) if x.bit_count() in (3, 4)}
    require(S == set(range(64)) - Z and len(S) == 29, 'Circuit difference set')
    require(set().union(*spaces) == Z | {0}, 'Horizontal union')
    duals = [{u for u in range(64) if all(parity(u & x) == 0 for x in B)} for B in spaces]
    require(set().union(*duals) == Z | {0}, 'Annihilator union')
    J = lambda x: x ^ (63 if parity(x) else 0)
    require(all({J(x) for x in B} == D for B, D in zip(spaces, duals)), 'J maps each layer to its annihilator')
    left, right = (0, 1, 2, 4), (3, 5)
    require(all(spaces[i] & spaces[j] == {0} for i in left for j in right), 'Cross-group intersections')
    left_labels = {y for y, i in enumerate(assignment) if i in left}
    require(left_labels == {0, 1, 2, 4, 6}, 'Odd label group')
    require(all(any((y in left_labels) != ((y ^ z) in left_labels)
                    for y in range(8)) for z in range(1, 8)), 'Every nonzero shift crosses groups')
    D = sums(E)
    require(D == {(x + 64 * y) for y in range(8) for x in range(64)
                  if y != 0 or x in Z | {0}}, 'Exact domain difference set')
    require(len(D) == 484, 'Difference-set cardinality')
    tiling(E, T)
    ordered_E = sorted(E)
    gram(ordered_E, sorted(L))

    normalized, nodes = normalized_cliques(set(range(512)) - D, 8)
    expected = {tuple(sorted(c ^ x for x in C)) for c in C}
    require(set(normalized) == expected and len(normalized) == 8, 'Exhaustive normalized complements')
    all_T = sorted({tuple(sorted(t ^ g for t in A)) for A in normalized for g in range(512)})
    require(len(all_T) == 512, 'All complement count')
    for complement in all_T:
        tiling(E, complement)

    quotients, quotient_nodes = normalized_cliques(S - {0}, 8)
    require(set(quotients) == expected, 'Exhaustive normalized quotient spectra')
    all_Q = sorted({tuple(sorted(q ^ a for q in Q)) for Q in quotients for a in range(64)})
    spectra = [sorted(q + 64 * y for q in Q for y in range(8)) for Q in all_Q]
    require(len(spectra) == 64, 'All spectrum count after analytic reduction')
    norm_values = set()
    for spectrum in spectra:
        gram(ordered_E, spectrum)
        norm_values.add(Fraction(sum(abs(v) for v in walsh(set(spectrum), 9)), 512))
    require(norm_values == {Fraction(15, 8)}, 'Exact spectrum Wiener norms')
    require(sum(0 in spectrum for spectrum in spectra) == 8, 'Normalized spectrum count')
    WC = walsh(C, 6)
    require(all(WC[u] == 7 - 2 * u.bit_count() + (-1) ** u.bit_count() for u in range(64)), 'Walsh formula for C')

    subspace_count = 0
    pivot_counts = Counter()
    subspace_complements = []
    for pivots, basis in rref_three_spaces(9):
        subspace_count += 1
        pivot_counts[pivots] += 1
        a, b, c = basis
        nonzero = (a, b, c, a ^ b, a ^ c, b ^ c, a ^ b ^ c)
        if not any(x in D for x in nonzero):
            subspace_complements.append(basis)
    gaussian = ((512 - 1) * (512 - 2) * (512 - 4)) // ((8 - 1) * (8 - 2) * (8 - 4))
    require(subspace_count == gaussian == 788035, 'Complete RREF coverage')
    require(subspace_complements == [], 'No subspace complement')
    results = {
        'status': 'PASS',
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'proof_dependency': 'The paper proves every spectrum is Q x F_2^3 and Q+Q is contained in S. The program verifies the structural hypotheses and exhausts that reduced problem.',
        'difference_size': len(D),
        'distinct_layer_nonzero_points': [sorted(B - {0}) for B in spaces],
        'annihilator_nonzero_points': [sorted(B - {0}) for B in duals],
        'normalized_complement_count': len(normalized),
        'complement_recursion_nodes': nodes,
        'all_tiling_complements': all_T,
        'spectrum_count': len(spectra),
        'normalized_spectrum_count': 8,
        'quotient_recursion_nodes': quotient_nodes,
        'all_spectra': spectra,
        'exact_integer_gram_checks': 1 + len(spectra),
        'spectrum_wiener_norms': sorted(map(str, norm_values)),
        'three_subspaces_enumerated': subspace_count,
        'subspace_complement_count': len(subspace_complements),
        'rref_counts_by_pivots': {','.join(map(str, p)): n for p, n in sorted(pivot_counts.items())},
        'elapsed_seconds': time.perf_counter() - started,
    }
    (ROOT / 'verification_results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps({k: v for k, v in results.items()
                      if k not in ('all_tiling_complements', 'all_spectra', 'rref_counts_by_pivots',
                                   'distinct_layer_nonzero_points', 'annihilator_nonzero_points')}, indent=2))


if __name__ == '__main__':
    main()
