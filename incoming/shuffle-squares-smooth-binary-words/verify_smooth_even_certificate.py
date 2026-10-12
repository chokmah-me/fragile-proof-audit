#!/usr/bin/env python3
"""Standalone checker for the finite smooth-tangram certificate.

This file intentionally imports no project or discovery code.  It:

1. regenerates every finite C-infinity word through length 40 by taking
   all primitives;
2. checks the exact count table and the certificate's word-set coverage;
3. replays every positive FIFO control with a plain deque; and
4. exhausts every equal-size support partition for every claimed
   exception.
"""

from __future__ import annotations

import argparse
from collections import defaultdict, deque
import hashlib
import itertools
import json
from pathlib import Path


EXPECTED_FORMAT = "smooth-even-shuffle-square-certificate-v1"
EXPECTED_SMOOTH_ATOMS = {
    "11",
    "22",
    "1212",
    "1221",
    "2112",
    "2121",
    "121121",
    "212212",
    "12112212",
    "21221121",
}


def finite_derivative(word: str) -> str | None:
    run_lengths: list[int] = []
    position = 0
    while position < len(word):
        end = position + 1
        while end < len(word) and word[end] == word[position]:
            end += 1
        run_length = end - position
        if run_length > 2:
            return None
        run_lengths.append(run_length)
        position = end
    if run_lengths and run_lengths[0] == 1:
        run_lengths.pop(0)
    if run_lengths and run_lengths[-1] == 1:
        run_lengths.pop()
    return "".join(map(str, run_lengths))


def all_primitives(parent: str) -> set[str]:
    if parent == "":
        return {"1", "2", "12", "21"}

    words: set[str] = set()
    left_choices = (1,) if parent.startswith("1") else (0, 1)
    right_choices = (1,) if parent.endswith("1") else (0, 1)
    for first_letter in "12":
        letter = first_letter
        central_runs: list[str] = []
        for run_length in map(int, parent):
            central_runs.append(letter * run_length)
            letter = "2" if letter == "1" else "1"
        central = "".join(central_runs)
        preceding_letter = "2" if first_letter == "1" else "1"
        following_letter = letter
        for add_left in left_choices:
            for add_right in right_choices:
                words.add(
                    (preceding_letter if add_left else "")
                    + central
                    + (following_letter if add_right else "")
                )
    return words


def regenerate_smooth_words(maximum_length: int) -> set[str]:
    generated = {"1", "2", "12", "21"}
    frontier = set(generated)
    while frontier:
        next_frontier: set[str] = set()
        for parent in frontier:
            for primitive in all_primitives(parent):
                if (
                    len(primitive) <= maximum_length
                    and primitive not in generated
                ):
                    next_frontier.add(primitive)
        for primitive in next_frontier:
            if finite_derivative(primitive) not in generated:
                raise AssertionError(
                    f"incomplete parent layer for {primitive}"
                )
        generated.update(next_frontier)
        frontier = next_frontier
    return generated


def is_tangram(word: str) -> bool:
    return word.count("1") % 2 == word.count("2") % 2 == 0


def tangram_atoms(word: str) -> list[str]:
    atoms: list[str] = []
    start = 0
    parity = [0, 0]
    for end, letter in enumerate(word, start=1):
        parity[int(letter) - 1] ^= 1
        if parity == [0, 0]:
            atoms.append(word[start:end])
            start = end
    if start != len(word):
        raise AssertionError(f"non-tangram passed to atomizer: {word}")
    return atoms


def complement(word: str) -> str:
    return word.translate(str.maketrans("12", "21"))


def classified_no_triple_atoms(maximum_length: int) -> set[str]:
    """The regular-form classification used by the human proof."""

    atoms = {"11", "22", "1212", "1221", "2121", "2112"}
    repetitions = 0
    while True:
        first = "1211" + "2211" * repetitions + "21"
        second = "1211" + "2211" * repetitions + "2212"
        if len(first) > maximum_length and len(second) > maximum_length:
            break
        for atom in (first, second):
            if len(atom) <= maximum_length:
                atoms.add(atom)
                atoms.add(complement(atom))
        repetitions += 1
    return atoms


def brute_no_triple_atoms(maximum_length: int) -> set[str]:
    layer = [""]
    atoms: set[str] = set()
    for _ in range(maximum_length):
        following: list[str] = []
        for prefix in layer:
            for letter in "12":
                word = prefix + letter
                if len(word) >= 3 and word[-3:] in {"111", "222"}:
                    continue
                following.append(word)
                if is_tangram(word) and tangram_atoms(word) == [word]:
                    atoms.add(word)
        layer = following
    return atoms


def replay_fifo_control(word: str, control: str) -> bool:
    if len(word) != len(control):
        return False
    waiting: deque[str] = deque()
    for letter, operation in zip(word, control, strict=True):
        if operation == "U":
            waiting.append(letter)
        elif operation == "D":
            if not waiting or waiting.popleft() != letter:
                return False
        else:
            return False
    return not waiting


def has_direct_shuffle_square(word: str) -> bool:
    if len(word) % 2:
        return False
    half = len(word) // 2
    positions = range(len(word))
    for first_support in itertools.combinations(positions, half):
        first_set = set(first_support)
        second_support = (
            position
            for position in positions
            if position not in first_set
        )
        first_word = "".join(word[position] for position in first_support)
        second_word = "".join(word[position] for position in second_support)
        if first_word == second_word:
            return True
    return False


def canonical_bytes(certificate: object) -> bytes:
    return json.dumps(
        certificate,
        sort_keys=True,
        separators=(",", ":"),
    ).encode()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("certificate", type=Path)
    parser.add_argument(
        "--expected-sha256",
        help="fail unless the canonical certificate has this digest",
    )
    args = parser.parse_args()

    raw = args.certificate.read_bytes()
    certificate = json.loads(raw)
    payload = canonical_bytes(certificate)
    if raw != payload:
        raise AssertionError("certificate JSON is not canonical")
    digest = hashlib.sha256(payload).hexdigest()
    if (
        args.expected_sha256 is not None
        and digest != args.expected_sha256
    ):
        raise AssertionError(
            f"SHA-256 mismatch: expected {args.expected_sha256},"
            f" observed {digest}"
        )
    if certificate.get("format") != EXPECTED_FORMAT:
        raise AssertionError("unknown certificate format")

    maximum_length = certificate["maximum_length"]
    if maximum_length != 40:
        raise AssertionError(f"unexpected maximum length {maximum_length}")
    smooth = regenerate_smooth_words(maximum_length)
    if len(smooth) != certificate["smooth_word_count"]:
        raise AssertionError("smooth-word total mismatch")

    by_length: dict[int, list[str]] = defaultdict(list)
    for word in smooth:
        by_length[len(word)].append(word)
    tangrams = {
        word
        for word in smooth
        if len(word) % 2 == 0 and is_tangram(word)
    }
    if len(tangrams) != certificate["smooth_tangram_count"]:
        raise AssertionError("smooth-tangram total mismatch")

    observed_counts: dict[str, list[int]] = {}
    for length in range(2, maximum_length + 1, 2):
        observed_counts[str(length)] = [
            len(by_length[length]),
            sum(is_tangram(word) for word in by_length[length]),
            sum(
                len(word) == length
                for word in certificate["exceptions"]
            ),
        ]
    if observed_counts != certificate["counts"]:
        raise AssertionError("per-length count table mismatch")

    if len(certificate["exceptions"]) != len(set(certificate["exceptions"])):
        raise AssertionError("duplicate exception in certificate")
    exceptions = set(certificate["exceptions"])
    controls = certificate["positive_controls"]
    if exceptions & controls.keys():
        raise AssertionError("word is both positive and exceptional")
    if exceptions | controls.keys() != tangrams:
        missing = tangrams - exceptions - controls.keys()
        extra = (exceptions | controls.keys()) - tangrams
        raise AssertionError(
            f"certificate coverage mismatch: missing={sorted(missing)},"
            f" extra={sorted(extra)}"
        )

    for word, control in controls.items():
        if not replay_fifo_control(word, control):
            raise AssertionError(f"invalid FIFO control for {word}")

    for word in tangrams:
        if not set(tangram_atoms(word)) <= EXPECTED_SMOOTH_ATOMS:
            raise AssertionError(f"unexpected smooth atom in {word}")

    brute_atoms = brute_no_triple_atoms(24)
    classified_atoms = classified_no_triple_atoms(24)
    if brute_atoms != classified_atoms:
        raise AssertionError(
            "no-triple atom classification mismatch:"
            f" missing={sorted(brute_atoms - classified_atoms)},"
            f" extra={sorted(classified_atoms - brute_atoms)}"
        )

    for word in exceptions:
        if len(word) > 16:
            raise AssertionError(f"overlong exception {word}")
        if has_direct_shuffle_square(word):
            raise AssertionError(f"false exception {word}")

    print(
        json.dumps(
            {
                "status": "PASS",
                "certificate_sha256": digest,
                "certificate_bytes": len(payload),
                "smooth_words_regenerated": len(smooth),
                "smooth_tangrams_covered": len(tangrams),
                "positive_controls_replayed": len(controls),
                "exceptions_directly_exhausted": len(exceptions),
                "no_triple_atoms_checked_through": 24,
                "imports_project_code": False,
            },
            sort_keys=True,
        ),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
