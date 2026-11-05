"""Independent brute-force verifier for the F2^9 tiling claim (arXiv:2610.42005).

Drafted by anthropic/claude-haiku-5.5 via OpenRouter or_call.py (effort
medium, 2026-11-05, two calls, $0.0115 total) per the standing
script-writing rule; adjudicated and repaired by the main agent before
running. Adjudication fixes: (1) example.json complement field is "T",
not the drafted "T0" (would have failed at load); (2) the drafted tail
referenced undefined names (Dset, comp, all_complements) and a
KeyError-prone tiling counter -- rewritten to reuse this file's own
helpers (normalized_census, all_translates, partition_ok) and the
sub_tiling counter; (3) headline-count requires added so the gate
fails closed on the claimed numbers, which are also printed raw.
Method: no clique search and no analytic reduction is imported for
complements -- every 7-subset of the 28 allowed differences is
enumerated and tested directly. Spectra use the same brute-force
enumeration over the reduced 8-point problem in F2^6 (see audit note
for the analytic-reduction dependency, whose finite hypotheses are
recomputed here). Subspaces are enumerated by an independent RREF
loop and counted against the Gaussian binomial.
Usage: python3 f2_9_tiling_independent.py <dir containing example.json and comparison_data.json>
"""

import itertools
import json
import sys
import time
from fractions import Fraction

T_BEGIN = time.time()
PAR = [bin(x).count("1") & 1 for x in range(512)]


def elapsed():
    return time.time() - T_BEGIN


def log(msg):
    print("[%9.2fs] %s" % (elapsed(), msg), flush=True)


def require(cond, msg):
    if not cond:
        raise SystemExit("REQUIRE FAILED: " + msg)


def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except (IOError, OSError, ValueError) as ex:
        raise SystemExit("REQUIRE FAILED: cannot load %s: %s" % (path, ex))


def get_key(obj, key, name):
    require(isinstance(obj, dict) and key in obj, name + ": missing field '" + key + "'")
    return obj[key]


def nchoose(n, k):
    r = 1
    for i in range(k):
        r = r * (n - i) // (i + 1)
    return r


def check_points(E, name):
    require(len(E) == 64, name + ": |E| must be 64, got %d" % len(E))
    require(len(set(E)) == 64, name + ": points not distinct")
    require(all(isinstance(x, int) and 0 <= x < 512 for x in E),
            name + ": point out of range 0..511")


def difference_set(E):
    D = set()
    for a in E:
        for b in E:
            D.add(a ^ b)
    return D


def partition_ok(E, T):
    for t in T:
        if (not isinstance(t, int)) or t < 0 or t > 511:
            return False
    counts = [0] * 512
    for e in E:
        for t in T:
            counts[e ^ t] += 1
    return all(c == 1 for c in counts)


def is_subspace(T):
    S = set(T)
    if 0 not in S:
        return False
    L = list(S)
    for a in L:
        for b in L:
            if (a ^ b) not in S:
                return False
    return True


def is_affine(T):
    if not T:
        return False
    m = min(T)
    return is_subspace([t ^ m for t in T])


def normalized_census(D, allowed, label):
    total = nchoose(len(allowed), 7)
    log("%s: exhaustive census over C(%d,7)=%d combinations" % (label, len(allowed), total))
    found = []
    for sub in itertools.combinations(allowed, 7):
        T = (0,) + sub
        ok = True
        for a in T:
            for b in T:
                x = a ^ b
                if x and x in D:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            found.append(T)
    log("%s: normalized complements found = %d" % (label, len(found)))
    return found


def all_translates(Ns):
    out = set()
    for N in Ns:
        for g in range(512):
            out.add(tuple(sorted(x ^ g for x in N)))
    return out


def make_WE(E):
    cache = {}

    def WE(u):
        if u not in cache:
            s = 0
            for e in E:
                s += -1 if PAR[e & u] else 1
            cache[u] = s
        return cache[u]
    return WE


def gram_ok(Lam, WE):
    for l in Lam:
        for l2 in Lam:
            if l != l2 and WE(l ^ l2) != 0:
                return False
    return True


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: python3 script.py DIR")
    base = sys.argv[1].rstrip("/\\")
    ex = load_json(base + "/example.json")
    cmp_data = load_json(base + "/comparison_data.json")
    summary = {}

    # ---------- Step 1 ----------
    log("STEP 1: principal difference set and allowed set")
    E = get_key(ex, "E", "example")
    check_points(E, "example E")
    D = difference_set(E)
    allowed = sorted(set(range(512)) - D)
    require(len(D) == 484, "|D| expected 484, got %d" % len(D))
    require(len(allowed) == 28, "allowed size expected 28, got %d" % len(allowed))
    log("|D|=%d, |allowed|=%d" % (len(D), len(allowed)))
    summary["D_size"] = len(D)
    summary["allowed_size"] = len(allowed)

    # ---------- Step 2 ----------
    log("STEP 2: claimed complement T0 partition check")
    T0 = get_key(ex, "T", "example")
    t0_ok = partition_ok(E, T0)
    require(t0_ok, "claimed T0 does not tile (counts not all 1)")
    summary["T0_partition_ok"] = t0_ok
    Lam_claim = ex.get("Lambda")
    if Lam_claim is not None:
        WE_claim = make_WE(E)
        try:
            summary["Lambda_claim_size"] = len(Lam_claim)
            summary["Lambda_claim_gram_ok"] = gram_ok(list(Lam_claim), WE_claim)
        except TypeError:
            summary["Lambda_claim_gram_ok"] = False
    log("T0 tiles E: %s" % t0_ok)

    # ---------- Step 3 ----------
    log("STEP 3: exhaustive normalized complement census (principal)")
    Ns = normalized_census(D, allowed, "principal")
    summary["principal_normalized_count"] = len(Ns)
    log("building translates of %d normalized complements" % len(Ns))
    tr = all_translates(Ns)
    summary["principal_distinct_complements"] = len(tr)
    log("distinct complements = %d; running partition check on each" % len(tr))
    pass_count = 0
    for T in tr:
        if partition_ok(E, T):
            pass_count += 1
    summary["principal_partition_pass_count"] = pass_count
    lin = sum(1 for T in tr if is_subspace(T))
    aff = sum(1 for T in tr if is_affine(T))
    summary["principal_linear_subspace_count"] = lin
    summary["principal_affine_subspace_count"] = aff
    log("partition passes=%d, linear=%d, affine=%d" % (pass_count, lin, aff))
    require(len(Ns) == 8, "expected 8 normalized complements, got %d" % len(Ns))
    require(len(tr) == 512, "expected 512 distinct complements, got %d" % len(tr))
    require(pass_count == 512, "expected 512 partition passes, got %d" % pass_count)
    require(lin == 0, "expected 0 linear subspace complements, got %d" % lin)
    require(aff == 0, "expected 0 affine subspace complements, got %d" % aff)

    # ---------- Step 4 ----------
    log("STEP 4: reduced spectra census")
    C = get_key(ex, "C", "example")
    Cset = set(C)
    S = set()
    for c in Cset:
        for c2 in Cset:
            S.add(c ^ c2)
    require(all(0 <= s < 64 for s in S), "spectral difference set must lie in F2^6 (0..63)")
    cand = sorted(S - {0})
    summary["spectral_S_size"] = len(S)
    summary["spectral_cand_size"] = len(cand)
    total_q = nchoose(len(cand), 7)
    log("spectral census: C(%d,7)=%d combinations" % (len(cand), total_q))
    Qn = []
    for sub in itertools.combinations(cand, 7):
        Q = (0,) + sub
        ok = True
        for a in Q:
            for b in Q:
                if (a ^ b) not in S:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            Qn.append(Q)
    summary["spectral_normalized_count"] = len(Qn)
    log("spectral normalized Q count = %d" % len(Qn))
    qt = set()
    for Q in Qn:
        for a in range(64):
            qt.add(tuple(sorted(q ^ a for q in Q)))
    summary["spectral_translate_distinct"] = len(qt)
    require(len(qt) == 64, "expected 64 distinct Q translates, got %d" % len(qt))
    WE = make_WE(E)
    passing_spectra = []
    for Qt in sorted(qt):
        Lam = sorted(q + 64 * y for q in Qt for y in range(8))
        if gram_ok(Lam, WE):
            passing_spectra.append(Lam)
    require(len(Qn) == 8, "expected 8 normalized Q, got %d" % len(Qn))
    summary["passing_spectra_count"] = len(passing_spectra)
    log("passing spectra = %d" % len(passing_spectra))
    log("Wiener norms over passing spectra (512-point naive Walsh)")
    wiener = set()
    for Lam in passing_spectra:
        vals = []
        for u in range(512):
            s = 0
            for l in Lam:
                s += -1 if PAR[l & u] else 1
            vals.append(abs(s))
        wiener.add(Fraction(sum(vals), 512))
    summary["wiener_norms"] = sorted(str(w) for w in wiener)

    # ---------- Step 5 ----------
    log("STEP 5: exhaustive RREF subspace census (3-dim subspaces of F2^9)")
    sub_total = 0
    sub_tiling = 0
    for piv in itertools.combinations(range(9), 3):
        free = []
        for i, p in enumerate(piv):
            for j in range(p + 1, 9):
                if j not in piv:
                    free.append((i, j))
        for bits in itertools.product((0, 1), repeat=len(free)):
            rows = [1 << p for p in piv]
            for (i, j), b in zip(free, bits):
                if b:
                    rows[i] |= 1 << j
            span = []
            for m in range(8):
                x = 0
                for k in range(3):
                    if (m >> k) & 1:
                        x ^= rows[k]
                span.append(x)
            sub_total += 1
            if (set(span) & D) == {0}:
                sub_tiling += 1
    gb = ((512 - 1) * (512 - 2) * (512 - 4)) // ((8 - 1) * (8 - 2) * (8 - 4))
    require(sub_total == gb, "subspace count does not match Gaussian binomial")
    summary["subspace_total"] = sub_total
    summary["subspace_tiling"] = sub_tiling
    summary["gaussian_binomial"] = gb
    log("subspaces: total=%d tiling=%d gaussian=%d" % (sub_total, sub_tiling, gb))
    require(sub_tiling == 0, "expected 0 tiling subspaces, got %d" % sub_tiling)

    # ---------- Step 6 ----------
    log("STEP 6: Goyal cross-check census")
    goyal_E = list(cmp_data["goyal"]["E"])
    check_points(goyal_E, "goyal E")
    Dg = difference_set(goyal_E)
    allowed_g = sorted(set(range(512)) - Dg)
    summary["goyal_D_size"] = len(Dg)
    summary["goyal_allowed_size"] = len(allowed_g)
    Ng = normalized_census(Dg, allowed_g, "goyal")
    trg = all_translates(Ng)
    gpass = sum(1 for T in trg if partition_ok(goyal_E, T))
    summary["goyal_normalized_count"] = len(Ng)
    summary["goyal_total_complements"] = len(trg)
    summary["goyal_partition_pass_count"] = gpass
    summary["complements_equal"] = (trg == tr)
    log("goyal: normalized=%d total=%d partition_pass=%d equal=%s"
        % (len(Ng), len(trg), gpass, trg == tr))

    # ---------- Step 7 ----------
    log("STEP 7: discrimination control (a set that DOES have a subspace complement)")
    E_ctrl = list(range(64))
    K = [0, 64, 128, 192, 256, 320, 384, 448]
    require(is_subspace(K), "control K is not a subspace")
    control_ok = partition_ok(E_ctrl, K)
    require(control_ok, "control partition failed: instrument cannot say yes")
    Dc = difference_set(E_ctrl)
    summary["control_subspace_tiles"] = control_ok
    summary["control_D_size"] = len(Dc)
    log("control: subspace K tiles the 6-dim subspace domain: %s, |D_ctrl|=%d"
        % (control_ok, len(Dc)))

    print("SUMMARY " + json.dumps(summary, sort_keys=True))
    log("done")


if __name__ == "__main__":
    main()
