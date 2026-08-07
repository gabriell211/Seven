#!/usr/bin/env python3
"""Read-only CI diagnostic for stable Seven SVBC call-site arity.

This script never generates or mutates Seven artifacts. It exists only to make
compiler/runtime gate failures actionable while the native self-host chain is
being brought up.
"""

from __future__ import annotations

import struct
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Field:
    name: str
    entry: int
    locals: int
    params: int


@dataclass(frozen=True)
class Instruction:
    opcode: int
    a: int
    b: int
    c: int
    source_ip: int


class Cursor:
    def __init__(self, data: bytes) -> None:
        self.data = data
        self.pos = 0

    def take(self, size: int) -> bytes:
        end = self.pos + size
        if end > len(self.data):
            raise ValueError(f"truncated SVBC at byte {self.pos}, need {size}")
        out = self.data[self.pos:end]
        self.pos = end
        return out

    def u8(self) -> int:
        return self.take(1)[0]

    def u32(self) -> int:
        return struct.unpack(">I", self.take(4))[0]

    def u64(self) -> int:
        return struct.unpack(">Q", self.take(8))[0]

    def text(self) -> str:
        return self.take(self.u32()).decode("utf-8")


def parse(path: Path) -> tuple[list[str], list[Field], list[Instruction]]:
    cur = Cursor(path.read_bytes())
    if cur.take(4) != b"SVBC":
        raise ValueError("validator expects stable SVBC1 magic 'SVBC'")
    version = cur.u32()
    if version != 1:
        raise ValueError(f"unsupported SVBC version {version}")

    names = [cur.text() for _ in range(cur.u32())]

    for _ in range(cur.u32()):
        tag = cur.u8()
        if tag == 0:
            pass
        elif tag == 2:
            cur.u8()
        elif tag == 3:
            cur.u64()
        elif tag == 4:
            cur.text()
        else:
            raise ValueError(f"unsupported constant tag {tag}")

    fields: list[Field] = []
    for _ in range(cur.u32()):
        name_index = cur.u32()
        if name_index >= len(names):
            raise ValueError(f"field name index out of bounds: {name_index}")
        entry = cur.u64()
        locals_count = cur.u32()
        params = cur.u32()
        effect_count = cur.u32()
        for _ in range(effect_count):
            effect_index = cur.u32()
            if effect_index >= len(names):
                raise ValueError(f"effect name index out of bounds: {effect_index}")
        fields.append(Field(names[name_index], entry, locals_count, params))

    instructions: list[Instruction] = []
    for _ in range(cur.u32()):
        instructions.append(
            Instruction(cur.u8(), cur.u32(), cur.u32(), cur.u32(), cur.u64())
        )

    if cur.pos != len(cur.data):
        raise ValueError(f"trailing bytes in SVBC: {len(cur.data) - cur.pos}")
    return names, fields, instructions


def caller_for(fields: list[Field], code_index: int) -> Field | None:
    owner: Field | None = None
    for field in fields:
        if field.entry <= code_index and (owner is None or field.entry > owner.entry):
            owner = field
    return owner


def validate(path: Path) -> int:
    _, fields, instructions = parse(path)
    failures = 0

    for code_index, instr in enumerate(instructions):
        # Stable SVBC raw opcode 16 == Chama.
        if instr.opcode != 16:
            continue

        caller = caller_for(fields, code_index)
        caller_name = caller.name if caller else "<sem-campo>"

        if instr.a >= len(fields):
            print(
                "SVBC-CALL target-out-of-bounds "
                f"caller={caller_name} code_index={code_index} source_ip={instr.source_ip} "
                f"target_index={instr.a} field_count={len(fields)} got={instr.b}",
                file=sys.stderr,
            )
            failures += 1
            continue

        target = fields[instr.a]
        if instr.b != target.params:
            print(
                "SVBC-CALL arity-mismatch "
                f"caller={caller_name} target={target.name} code_index={code_index} "
                f"source_ip={instr.source_ip} got={instr.b} expected={target.params}",
                file=sys.stderr,
            )
            failures += 1

    if failures:
        print(f"SVBC call validation failed: {failures} invalid call site(s)", file=sys.stderr)
        return 1

    print(f"SVBC call validation OK: {len(fields)} fields, {len(instructions)} instructions")
    return 0


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} IMAGE.svbc", file=sys.stderr)
        return 2
    try:
        return validate(Path(sys.argv[1]))
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"SVBC validator error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
