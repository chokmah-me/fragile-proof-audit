# Draft — author contact for q-TSPP milestone 3 (DO NOT SEND without user approval)

**To:** Christoph Koutschan (christoph.koutschan@risc.jku.at — verify address before sending)
**Subject:** Request: q=1 diagonal recurrence coefficients from "A computer proof of Stembridge's TSPP theorem" (arXiv:0906.1018)

---

Dear Dr. Koutschan,

I am working on a Lean 4 formalization of the holonomic-ansatz proof from
your paper "A computer proof of Stembridge's TSPP theorem" (arXiv:0906.1018),
as part of a private proof-audit campaign. The formalization follows your
paper's architecture: the three identities (3.1)–(3.3), with the
"rational-function certificate + finite initial-value check" steps verified
in Lean's kernel.

I have completed a parametric formalization of identity (3.2) (the diagonal
B'(n,n) = 1): the closing argument — order-7 recurrence with (S_n−1) right
factor, nonvanishing leading coefficient, 7 initial values ⇒ d = 1 by
recurrence uniqueness — is fully proved. What I am missing is the explicit
numerical certificate data from §5.3:

1. The **order-7 recurrence coefficients** for the diagonal B'(n,n) (the
   output of `DFiniteSubstitute` on the ∂-finite description of B'(n,j)),
   i.e. the polynomials p_0(n), …, p_7(n). The paper prints only the
   leading-coefficient factorization
   256(2n+3)(2n+5)(2n+7)(2n+9)(2n+11)²(2n+13)²·p_1·p_2, not the operator itself.
2. If available, the **∂-finite description of B'(n,j)** itself (the Gröbner
   basis / recurrence system), which would let me verify the recurrence
   derivation in the formalization.

I have checked the arXiv source package, your PhD thesis, and the Wayback
Machine — the q=1 certificate data does not appear in any public source
(the q-case material from risc.jku.at/people/ckoutsch/qtspp/ I was able to
recover via the Wayback Machine, but it does not contain the q=1 diagonal
recurrence). Since §5.3 notes the computation takes "a couple of minutes,"
I am hoping re-running it and sharing the operator is a small request.

The formalization is for a private research repository (not yet public); I
will of course credit the source of the certificate data. If you would
prefer, I am happy to work from whatever format is convenient (Mathematica
expression, plain text, etc.).

Thank you for your time, and for the beautiful proof.

Best regards,
[User name]
[Affiliation / context]

---

**Notes for user:**
- Verify Koutschan's current email (RISC JKU or koutschan.de).
- Consider CC'ing Manuel Kauers (guessing) or Doron Zeilberger only if Koutschan does not respond.
- Do NOT send without explicit user approval.
