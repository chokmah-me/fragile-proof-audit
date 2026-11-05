#!/usr/bin/env python3
"""Exact checks for the comparison appendix, using only the standard library.

Keep this file, comparison_data.json, verify_example.py, and example.json in
one directory. Run python3 verify_comparison.py (Python >=3.10).

The common-layer theorem in the paper proves that EVERY spectrum is Q x F_2^3
and that Q+Q is contained in C+C. The finite search below exhausts that reduced
problem. It is not a search over all 64-point subsets of F_2^9 and is not a
replacement for the theorem. Affine inequivalence follows from the intrinsic
horizontal space and the fiber-direction invariant proved in the appendix.
"""
from collections import Counter
from fractions import Fraction
from pathlib import Path
import hashlib
import json

from verify_example import (checked_set, gram, normalized_cliques, parity,
                            require, span, sums, tiling, walsh)

ROOT = Path(__file__).resolve().parent
EXPECTED_GOYAL_BASES = [[11, 22, 37], [7, 26, 43], [14, 23, 35], [13, 22, 39],
                        [7, 26, 43], [11, 21, 39], [15, 19, 38], [11, 23, 38]]
PINNED_COMMIT = '0df6158e3818b14d202147a0f31da0f401dd36d8'


def annihilator(B):
    return {u for u in range(64) if all(parity(u & b) == 0 for b in B)}


def periods(A, dimension):
    return [p for p in range(1 << dimension) if {a ^ p for a in A} == A]


def check_domain(name, points, bases, C, S, Z):
    E = checked_set(points, 64, 9, name)
    require(len(bases) == 8, name + ': eight layers')
    layers = []
    for y, basis in enumerate(bases):
        checked_set(basis, 3, 6, name + ': basis ' + str(y))
        B = span(basis)
        require(len(B) == 8, name + ': three independent basis vectors')
        layers.append(B)
    require(E == {x + 64*y for y, B in enumerate(layers) for x in B},
            name + ': reconstruction from printed bases')
    D = sums(E)
    missing = set(range(512)) - D
    require(missing == S - {0}, name + ': exact saturated difference identity')
    require(set.union(*layers) == Z | {0}, name + ': horizontal union')
    require(span(missing) == set(range(64)), name + ': intrinsic horizontal space')
    duals = [annihilator(B) for B in layers]
    require(set.union(*duals) == Z | {0}, name + ': annihilator union')
    J = lambda x: x ^ (63 if parity(x) else 0)
    require(all({J(x) for x in B} == dual for B, dual in zip(layers, duals)),
            name + ': J maps layers to annihilators')
    require(periods(E, 9) == [0], name + ': aperiodic domain')

    # Complement completeness is a finite eight-point problem on the exact
    # allowed differences. No search cutoff or random choice is used.
    normalized, nodes = normalized_cliques(missing, 8)
    expected_normalized = {tuple(sorted(c ^ a for c in C)) for a in C}
    require(set(normalized) == expected_normalized,
            name + ': exhaustive normalized complements')
    complements = sorted({tuple(sorted(t ^ g for t in T))
                          for T in normalized for g in range(512)})
    expected_complements = {tuple(sorted(c ^ g for c in C)) for g in range(512)}
    require(set(complements) == expected_complements and len(complements) == 512,
            name + ': complete complement family')
    for T in complements:
        tiling(E, T)
        require(periods(set(T), 9) == [0], name + ': no periodic complement')
    require(sum(0 in T for T in complements) == 8,
            name + ': eight complements containing zero')

    # Completeness here additionally uses the analytic product reduction in
    # the common-layer theorem; these checks verify its hypotheses above.
    quotients, quotient_nodes = normalized_cliques(S - {0}, 8)
    require(set(quotients) == expected_normalized,
            name + ': exhaustive normalized horizontal spectrum factors')
    Q_all = {tuple(sorted(q ^ a for q in Q)) for Q in quotients for a in range(64)}
    spectra = sorted({tuple(sorted(q + 64*y for q in Q for y in range(8)))
                      for Q in Q_all})
    require(len(spectra) == 64 and sum(0 in L for L in spectra) == 8,
            name + ': spectrum counts after analytic reduction')
    L0 = sorted(c + 64*y for c in C for y in range(8))
    gram(sorted(E), L0)
    norms = set()
    for L in spectra:
        gram(sorted(E), L)
        norms.add(Fraction(sum(abs(x) for x in walsh(set(L), 9)), 512))
    require(norms == {Fraction(15, 8)}, name + ': exact Wiener norms')
    multiplicities = sorted(Counter(map(frozenset, layers)).values(), reverse=True)
    return {
        'cardinality': len(E), 'difference_size': len(D),
        'intrinsic_horizontal_space': list(range(64)),
        'layer_nonzero_points': [sorted(B - {0}) for B in layers],
        'annihilator_nonzero_points': [sorted(B - {0}) for B in duals],
        'direction_multiplicities': multiplicities,
        'periods': [0], 'periodic_complement_count': 0,
        'all_complements': [list(T) for T in complements],
        'all_spectra_after_analytic_reduction': [list(L) for L in spectra],
        'normalized_complement_count': len(normalized),
        'normalized_spectrum_count': 8,
        'complement_recursion_nodes': nodes,
        'quotient_recursion_nodes': quotient_nodes,
        'exact_integer_gram_checks': 65,
        'spectrum_wiener_norms': sorted(map(str, norms)),
    }, layers, duals


def main():
    source = ROOT / 'comparison_data.json'
    data = json.loads(source.read_text())
    original = json.loads((ROOT / 'example.json').read_text())
    require(data['provenance']['commit'] == PINNED_COMMIT, 'Pinned Goyal source version')
    C = checked_set(data['C'], 8, 6, 'C')
    require(C == {0, 1, 2, 4, 8, 16, 32, 63} == set(original['C']), 'Same circuit')
    S = sums(C)
    Z = {x for x in range(64) if x.bit_count() in (3, 4)}
    require(S == set(range(64)) - Z, 'Circuit pair-sum weights')
    require(periods(C, 6) == [0], 'Aperiodicity of the circuit')
    goyal = data['goyal']
    require(goyal['layer_bases'] == EXPECTED_GOYAL_BASES, 'Printed Goyal bases')
    own, own_layers, own_duals = check_domain(
        'Ferguson-Iosevich', original['E'], original['layer_bases'], C, S, Z)
    other, layers, duals = check_domain(
        'Goyal', goyal['E'], goyal['layer_bases'], C, S, Z)
    require(other['layer_nonzero_points'] == goyal['layer_nonzero_points'],
            'Printed Goyal nonzero subspace table')
    require(other['annihilator_nonzero_points'] == goyal['annihilator_nonzero_points'],
            'Printed Goyal annihilator table')
    require(set(goyal['explicit_complement']) == C, 'Goyal complement coordinates')
    require(sorted(goyal['explicit_spectrum']) ==
            sorted(c + 64*y for c in C for y in range(8)), 'Goyal spectrum coordinates')

    # The nine rows of the cross-fiber table prove coverage of each nonzero
    # vertical difference; the last three rows cover the exceptional value 4.
    expected_pairs = [(1, 2, 3, None), (2, 0, 2, None), (3, 1, 2, None),
                      (5, 3, 6, None), (6, 0, 6, None), (7, 1, 6, None),
                      (4, 0, 4, 29), (4, 1, 5, 19), (4, 3, 7, 14)]
    require([tuple(row) for row in data['cross_fiber_certificate']] == expected_pairs,
            'Printed cross-fiber certificate rows')
    covered = {a: set() for a in range(1, 8)}
    for a, i, j, normal in expected_pairs:
        require(i ^ j == a, 'Cross-fiber label')
        expected_intersection = ({0} if normal is None else
                                 {0, {(0, 4): 29, (1, 5): 44, (3, 7): 49}[(i, j)]})
        require(layers[i] & layers[j] == expected_intersection,
                'Printed layer intersection')
        if normal is not None:
            require(all((b & normal).bit_count() == 2
                        for k in (i, j) for b in EXPECTED_GOYAL_BASES[k]),
                    'Each printed normal-basis intersection has weight two')
        common_dual = duals[i] & duals[j]
        expected_dual = {0} if normal is None else {0, normal}
        require(common_dual == expected_dual, 'Printed dual intersection')
        actual_sum = sums(layers[i], layers[j])
        expected_sum = (set(range(64)) if normal is None else
                        {x for x in range(64) if parity(x & normal) == 0})
        require(actual_sum == expected_sum, 'Printed cross-fiber sumspace')
        covered[a] |= actual_sum
    require(29 ^ 19 == 14, 'Exceptional hyperplane relation')
    require(all(covered[a] == set(range(64)) for a in covered),
            'All nonzero fibers covered by the printed certificate')

    require(own['direction_multiplicities'] == [2, 2, 1, 1, 1, 1],
            'Six directions in the first domain')
    require(other['direction_multiplicities'] == [2, 1, 1, 1, 1, 1, 1],
            'Seven directions in Goyal domain')
    require(own['all_complements'] == other['all_complements'],
            'Identical complete complement families')
    require(own['all_spectra_after_analytic_reduction'] ==
            other['all_spectra_after_analytic_reduction'], 'Identical complete spectrum families')
    result = {
        'status': 'PASS',
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'proof_dependency': ('Completeness of the spectrum lists uses the common-layer theorem: '
                             'every spectrum is Q x F_2^3 with Q+Q contained in C+C. '
                             'Affine inequivalence uses the intrinsic-space and fiber-direction '
                             'invariant proved in the appendix.'),
        'ferguson_iosevich': own,
        'goyal': other,
        'same_complement_families': True,
        'same_spectrum_families': True,
        'distinct_affine_invariants': True,
        'cross_fiber_certificate_checked': True,
        'lean_replay_performed': False,
    }
    (ROOT / 'comparison_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({
        'status': result['status'],
        'domains': 2,
        'complements_checked_per_domain': 512,
        'spectra_checked_per_domain': 64,
        'integer_gram_checks_per_domain': 65,
        'direction_multiplicities': [own['direction_multiplicities'], other['direction_multiplicities']],
        'periods_of_each_domain': [0],
        'periodic_complement_count': 0,
        'spectrum_wiener_norms': ['15/8'],
        'same_complement_families': True,
        'same_spectrum_families': True,
        'cross_fiber_certificate_checked': True,
        'proof_dependency': result['proof_dependency'],
    }, indent=2))


if __name__ == '__main__':
    main()
