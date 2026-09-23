/* liouville_sieve.c
 *
 * Clean-room segmented sieve for the Liouville function lambda(n) = (-1)^Omega(n)
 * and its summatory function L(n) = sum_{k=1}^{n} lambda(k).
 *
 * Purpose: independently recompute Tanaka's smallest counterexample to Polya's
 * conjecture (L(906150257) = +1, with L(n) <= 0 for 2 <= n < 906150257) and emit
 * chunk certificates that make the claim checkable by an independent verifier.
 *
 * Method (integer-only, no floating point):
 *   For each segment [lo, hi): cofactor[i] starts at n = lo+i, parity[i] = 0.
 *   For each prime p with p*p <= N: for each multiple m of p in the segment,
 *   divide p out of the cofactor fully, flipping parity once per factor.
 *   Exact division by odd p uses the 2-adic inverse p^{-1} mod 2^64 (two
 *   multiplies instead of a hardware divide); the divisibility test
 *       (__uint128_t)q * p != c   with q = c * inv(p) mod 2^64
 *   is exact: if p | c then q = c/p as integers and the check passes;
 *   if p does not divide c the 128-bit product differs from c.
 *   (p = 2 has no inverse mod 2^64 and is stripped separately via ctz.)
 *   After all p <= sqrt(N), a remaining cofactor > 1 is prime (any composite
 *   remainder would have a factor <= sqrt(N), already divided out), so parity
 *   flips once more. lambda(n) = +1 iff parity is even.
 *
 * Convention: L(1) = lambda(1) = +1 (Omega(1) = 0). The sieve covers n >= 2;
 * the running sum starts at L = 1. Polya's conjecture is stated for n >= 2,
 * so first-crossing / max tracking is over n >= 2 only.
 *
 * Usage:
 *   liouville_sieve N                        # stats only (anchors)
 *   liouville_sieve N chunk_size certdir     # stats + chunk certificates
 *
 * Exit 0 on success. Compile: gcc -O3 -o liouville_sieve liouville_sieve.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>
#include <limits.h>

#define SEG_SIZE (1u << 20)  /* numbers per segment; ~9 MB working set */

/* p^{-1} mod 2^64 for odd p, Newton iteration. */
static uint64_t inv64(uint64_t p)
{
    uint64_t x = 1;
    for (int i = 0; i < 6; ++i)
        x = x * (2u - p * x);
    return x;
}

/* Primes <= lim via Eratosthenes. Returns malloc'd array; count in *np_out. */
static int *gen_primes(int lim, int *np_out)
{
    unsigned char *comp = calloc((size_t)lim + 1, 1);
    int *primes = malloc(((size_t)lim + 1) * sizeof(int));
    int np = 0;
    if (!comp || !primes) { fprintf(stderr, "out of memory\n"); exit(1); }
    for (int i = 2; i <= lim; ++i) {
        if (!comp[i]) {
            primes[np++] = i;
            if ((int64_t)i * i <= lim)
                for (int j = i * i; j <= lim; j += i)
                    comp[j] = 1;
        }
    }
    free(comp);
    *np_out = np;
    return primes;
}

static uint64_t cof[SEG_SIZE];
static unsigned char par[SEG_SIZE];

static void write_cert(FILE *f, uint64_t chunk, uint64_t lo, uint64_t hi,
                       int64_t L_before, int64_t sum_lambda,
                       int64_t max_prefix, uint64_t argmax_prefix,
                       uint64_t first_cross, int64_t L_at_first_cross,
                       int has_before, int64_t max_prefix_before_first)
{
    fprintf(f,
        "{\n"
        "  \"chunk\": %" PRIu64 ",\n"
        "  \"lo\": %" PRIu64 ",\n"
        "  \"hi\": %" PRIu64 ",\n"
        "  \"count\": %" PRIu64 ",\n"
        "  \"L_before\": %" PRId64 ",\n"
        "  \"sum_lambda\": %" PRId64 ",\n"
        "  \"max_prefix\": %" PRId64 ",\n"
        "  \"argmax_prefix\": %" PRIu64 ",\n"
        "  \"first_cross\": %" PRIu64 ",\n",
        chunk, lo, hi, hi - lo + 1, L_before, sum_lambda,
        max_prefix, argmax_prefix, first_cross);
    if (first_cross)
        fprintf(f, "  \"L_at_first_cross\": %" PRId64 ",\n", L_at_first_cross);
    else
        fprintf(f, "  \"L_at_first_cross\": null,\n");
    if (has_before)
        fprintf(f, "  \"max_prefix_before_first\": %" PRId64 ",\n", max_prefix_before_first);
    else
        fprintf(f, "  \"max_prefix_before_first\": null,\n");
    fprintf(f,
        "  \"L_convention\": \"L(n)=sum_{k=1}^{n} lambda(k); L(1)=+1; sieve covers n>=2\"\n"
        "}\n");
}

int main(int argc, char **argv)
{
    if (argc < 2 || argc == 3) {
        fprintf(stderr, "usage: %s N [chunk_size certdir]\n", argv[0]);
        return 2;
    }
    uint64_t N = strtoull(argv[1], 0, 10);
    uint64_t chunk_size = 0;
    const char *certdir = NULL;
    if (argc >= 4) {
        chunk_size = strtoull(argv[2], 0, 10);
        certdir = argv[3];
        if (chunk_size == 0 || N < 2) {
            fprintf(stderr, "need N >= 2 and chunk_size > 0\n");
            return 2;
        }
    }
    if (N < 2) { fprintf(stderr, "need N >= 2\n"); return 2; }

    /* primes up to 100000 cover sqrt(N) for N <= 1e10 */
    int np = 0;
    int *primes = gen_primes(100000, &np);
    uint64_t *invs = malloc((size_t)np * sizeof(uint64_t));
    int nuse = 0;
    for (int i = 0; i < np; ++i) {
        uint64_t p = (uint64_t)primes[i];
        if (p * p > N)
            break;
        invs[nuse] = inv64(p);
        ++nuse;
    }

    int64_t L = 1;              /* L(1) = lambda(1) = +1 */
    uint64_t first_cross = 0;   /* first n >= 2 with L(n) > 0 */
    int64_t maxL = 1;
    uint64_t argmaxL = 1;

    /* chunk certificate state */
    uint64_t chunk = 0, chunk_lo = 2;
    int64_t csum = 0;                 /* sum of lambda over current chunk */
    int64_t cpref = 0;                /* running prefix within chunk */
    int64_t cmax = INT64_MIN;         /* max relative prefix in chunk */
    uint64_t cargmax = 0;
    uint64_t cfirst = 0;              /* first n in chunk with L(n) > 0 */
    int64_t cLfirst = 0;
    int64_t cmax_before = INT64_MIN;  /* max relative prefix for k < cfirst */
    int64_t L_before = 1;             /* L(chunk_lo - 1) */

    for (uint64_t lo = 2; lo <= N; ) {
        uint64_t hi = lo + SEG_SIZE;
        if (hi > N + 1)
            hi = N + 1;
        size_t n = (size_t)(hi - lo);

        for (size_t i = 0; i < n; ++i) {
            cof[i] = lo + i;
            par[i] = 0;
        }
        /* p = 2 has no inverse mod 2^64: strip factors of 2 via ctz */
        {
            uint64_t m = (lo + 1) & ~1ULL;  /* first even >= lo */
            for (; m < hi; m += 2) {
                size_t i = (size_t)(m - lo);
                uint64_t c = cof[i];  /* >= 2 here, ctz defined */
                unsigned t = __builtin_ctzll(c);
                par[i] ^= (t & 1u);
                cof[i] = c >> t;
            }
        }
        for (int pi = 1; pi < nuse; ++pi) {  /* odd primes only */
            uint64_t p = (uint64_t)primes[pi];
            uint64_t inv = invs[pi];
            uint64_t m = (lo + p - 1) / p * p;
            for (; m < hi; m += p) {
                size_t i = (size_t)(m - lo);
                uint64_t c = cof[i];
                for (;;) {
                    uint64_t q = c * inv;  /* mod 2^64 */
                    if ((unsigned __int128)q * p != c)
                        break;
                    c = q;
                    par[i] ^= 1;
                }
                cof[i] = c;
            }
        }

        for (size_t i = 0; i < n; ++i) {
            uint64_t nn = lo + i;
            unsigned char pr = par[i] ^ (cof[i] > 1 ? 1 : 0);
            int lam = pr ? -1 : 1;
            L += lam;

            if (first_cross == 0 && L > 0)
                first_cross = nn;
            if (L > maxL) {
                maxL = L;
                argmaxL = nn;
            }

            if (certdir) {
                uint64_t ci = (nn - 2) / chunk_size;
                if (ci != chunk) {
                    /* finalize previous chunk [chunk_lo, nn-1] */
                    char path[1024];
                    snprintf(path, sizeof(path), "%s/cert_%04" PRIu64 ".json",
                             certdir, chunk);
                    FILE *f = fopen(path, "w");
                    if (!f) { perror("fopen cert"); return 1; }
                    write_cert(f, chunk, chunk_lo, nn - 1, L_before, csum,
                               cmax, cargmax, cfirst, cLfirst,
                               cfirst != 0, cmax_before);
                    fclose(f);
                    ++chunk;
                    chunk_lo = nn;
                    csum = 0; cpref = 0;
                    cmax = INT64_MIN; cargmax = 0;
                    cfirst = 0; cLfirst = 0;
                    cmax_before = INT64_MIN;
                    L_before = L - lam;  /* L(nn-1) */
                }
                csum += lam;
                if (cfirst == 0 && L > 0) {
                    cfirst = nn;
                    cLfirst = L;
                    cmax_before = cmax;  /* max over k < nn */
                }
                cpref += lam;
                if (cpref > cmax) {
                    cmax = cpref;
                    cargmax = nn;
                }
            }
        }
        lo = hi;
    }

    if (certdir) {
        char path[1024];
        snprintf(path, sizeof(path), "%s/cert_%04" PRIu64 ".json", certdir, chunk);
        FILE *f = fopen(path, "w");
        if (!f) { perror("fopen cert"); return 1; }
        write_cert(f, chunk, chunk_lo, N, L_before, csum, cmax, cargmax,
                   cfirst, cLfirst, cfirst != 0, cmax_before);
        fclose(f);

        snprintf(path, sizeof(path), "%s/stats.json", certdir);
        f = fopen(path, "w");
        if (!f) { perror("fopen stats"); return 1; }
        fprintf(f,
            "{\n"
            "  \"N\": %" PRIu64 ",\n"
            "  \"L_N\": %" PRId64 ",\n"
            "  \"first_cross\": %" PRIu64 ",\n"
            "  \"max_L\": %" PRId64 ",\n"
            "  \"argmax_L\": %" PRIu64 ",\n"
            "  \"n_chunks\": %" PRIu64 ",\n"
            "  \"chunk_size\": %" PRIu64 ",\n"
            "  \"domain\": \"n>=2; L(1)=+1; L(n)=sum_{k=1}^{n} lambda(k)\",\n"
            "  \"generator\": \"polya/src/liouville_sieve.c\",\n"
            "  \"compiler\": \"%s\"\n"
            "}\n",
            N, L, first_cross, maxL, argmaxL, chunk + 1, chunk_size,
#ifdef __VERSION__
            __VERSION__
#else
            "unknown"
#endif
        );
        fclose(f);
    }

    printf("{\"N\":%" PRIu64 ",\"L_N\":%" PRId64
           ",\"first_cross\":%" PRIu64 ",\"max_L\":%" PRId64
           ",\"argmax_L\":%" PRIu64 "}\n",
           N, L, first_cross, maxL, argmaxL);

    free(primes);
    free(invs);
    return 0;
}
