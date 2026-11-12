import csv
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "analyze_wram.py"
SIZE = 0x20000


class AnalyzeWramTests(unittest.TestCase):
    def test_detects_changes_and_writes_csv(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            before = root / "before.bin"
            after = root / "after.bin"
            output = root / "result.csv"
            before.write_bytes(bytes(SIZE))
            changed = bytearray(SIZE)
            changed[0x07A2] = 0x03
            changed[0x2000:0x2002] = b"AB"
            after.write_bytes(changed)

            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(before), str(after), "-o", str(output)],
                check=True, capture_output=True, text=True,
            )
            self.assertIn("bytes alterados: 3", result.stdout)
            with output.open(newline="", encoding="utf-8") as fp:
                rows = list(csv.DictReader(fp))
            self.assertEqual(len(rows), 3)
            self.assertEqual(rows[0]["WRAM_OFFSET"], "0x007A2")
            self.assertIn("P1 character ID", rows[0]["REFERENCIA_CONHECIDA"])

    def test_rejects_wrong_snapshot_size(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            before = root / "before.bin"
            after = root / "after.bin"
            before.write_bytes(b"short")
            after.write_bytes(bytes(SIZE))
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(before), str(after)],
                capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("esperado 131072 bytes", result.stderr)


if __name__ == "__main__":
    unittest.main()
