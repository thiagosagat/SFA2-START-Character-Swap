#!/usr/bin/env python3
"""Compare two BizHawk SNES WRAM snapshots without claiming unknown fields are life."""
from __future__ import annotations
import argparse
import csv
from pathlib import Path

EXPECTED_SIZE = 0x20000
KNOWN = {
    0x07A2: "P1 character ID (reference from ASM)",
    0x0A22: "P2 character ID (reference from ASM)",
    0x1C07: "P1 moveset cache (reference from ASM)",
    0x1C08: "P2 moveset cache (reference from ASM)",
}


def load(path: Path) -> bytes:
    data = path.read_bytes()
    if len(data) != EXPECTED_SIZE:
        raise SystemExit(
            f"{path}: tamanho {len(data)}; esperado {EXPECTED_SIZE} bytes "
            "(WRAM SNES 128 KiB)."
        )
    return data


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("before", type=Path, help="SFA2_WRAM_ANTES.bin")
    parser.add_argument("after", type=Path, help="SFA2_WRAM_DEPOIS.bin")
    parser.add_argument("-o", "--output", type=Path, default=Path("SFA2_ANALISE_WRAM.csv"))
    parser.add_argument(
        "--context", type=int, default=4,
        help="bytes de contexto antes/depois de cada alteração (padrão: 4)"
    )
    args = parser.parse_args()
    if args.context < 0 or args.context > 64:
        parser.error("--context deve ficar entre 0 e 64")

    before, after = load(args.before), load(args.after)
    changed = [i for i, (a, b) in enumerate(zip(before, after)) if a != b]
    print(f"WRAM: {EXPECTED_SIZE} bytes | bytes alterados: {len(changed)}")
    if not changed:
        print("Nenhuma diferença encontrada. Confira se as capturas foram feitas em momentos diferentes.")
        return 0

    with args.output.open("w", newline="", encoding="utf-8") as fp:
        writer = csv.writer(fp)
        writer.writerow(["WRAM_OFFSET", "CPU_ADDRESS", "ANTES", "DEPOIS", "REFERENCIA_CONHECIDA"])
        for offset in changed:
            cpu = 0x7E0000 + offset
            writer.writerow([
                f"0x{offset:05X}", f"0x{cpu:06X}", f"0x{before[offset]:02X}",
                f"0x{after[offset]:02X}", KNOWN.get(offset, "")
            ])

    regions: list[tuple[int, int]] = []
    start = previous = changed[0]
    for offset in changed[1:]:
        if offset != previous + 1:
            regions.append((start, previous))
            start = offset
        previous = offset
    regions.append((start, previous))

    print(f"Regioes contiguas: {len(regions)} | CSV: {args.output.resolve()}")
    for start, end in regions[:100]:
        lo, hi = max(0, start - args.context), min(EXPECTED_SIZE, end + args.context + 1)
        old = " ".join(f"{v:02X}" for v in before[lo:hi])
        new = " ".join(f"{v:02X}" for v in after[lo:hi])
        note = f" | {KNOWN[start]}" if start in KNOWN else ""
        print(
            f"WRAM 0x{start:05X}-0x{end:05X} "
            f"(CPU 0x{0x7E0000+start:06X}-0x{0x7E0000+end:06X}){note}"
        )
        print(f"  antes:  {old}")
        print(f"  depois: {new}")
    if len(regions) > 100:
        print(f"... mais {len(regions)-100} regioes omitidas da tela; todas estao no CSV.")

    print(
        "\nIMPORTANTE: diferenca isolada nao identifica vida. Repita com varios golpes, "
        "P1 e P2, e compare os mesmos pontos."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
