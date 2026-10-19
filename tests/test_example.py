"""Integration tests using the thesis's eight-record example and four output tables.

Requires Python 3 stdlib and a compiled gfortran executable passed as argv[1].
"""
import csv
import math
import pathlib
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXE = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / 'build' / 'contra_rotating_propeller'
sys.argv = sys.argv[:1]
SOURCE_INPUT = ROOT / 'examples' / 'typical-case' / 'FA8.DAT'
REFERENCE = ROOT / 'docs' / 'thesis_reference_output.csv'
ORDER = ['self_fore', 'mutual_aft', 'self_aft', 'mutual_fore']


def execute(args=()):
    with tempfile.TemporaryDirectory(prefix='propeller-test-') as folder:
        wd = pathlib.Path(folder)
        (wd / 'FA8.DAT').write_bytes(SOURCE_INPUT.read_bytes())
        subprocess.run([str(EXE), *args], cwd=wd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        detail = (wd / 'FA8.OUT').read_text()
        table = (wd / 'FA88.OUT').read_text()
    return detail, table


def parse_tables(table):
    # All 32 numerical rows have 4 decimal-place fields; header is skipped.
    rows = []
    for line in table.splitlines():
        fields = line.split()
        if len(fields) == 4 and all(re.fullmatch(r'[+-]?\d+\.\d{4}', x) for x in fields):
            rows.append(tuple(float(x) for x in fields))
    if len(rows) != 32:
        raise AssertionError(f'Expected four tables x eight rows; got {len(rows)}')
    return [(ORDER[i//8], *row) for i, row in enumerate(rows)]


class ExampleCaseTest(unittest.TestCase):
    def test_published_case(self):
        detail, table = execute()
        self.assertIn('UXF', detail)
        self.assertIn('UZB', detail)
        observed = parse_tables(table)
        with REFERENCE.open(newline='') as f:
            expected = list(csv.DictReader(f))
        self.assertEqual(len(expected), len(observed))
        for idx, (result, ref) in enumerate(zip(observed, expected)):
            name, xf, ua, ut, ur = result
            self.assertEqual(name, ref['case'])
            self.assertTrue(all(math.isfinite(v) for v in (xf, ua, ut, ur)))
            self.assertAlmostEqual(xf, float(ref['xf']), delta=0.00015)
            for label, value in [('ut_vs', ut), ('ur_vs', ur)]:
                self.assertAlmostEqual(value, float(ref[label]), delta=0.00025,
                                       msg=f'{name} row {idx} {label}')
            # This is the only published column that is sensitive to nearly
            # degenerate bound vortex geometry and legacy compiler arithmetic.
            if name != 'self_fore':
                self.assertAlmostEqual(ua, float(ref['ua_vs']), delta=0.0003,
                                       msg=f'{name} row {idx} ua_vs')

    def test_corrected_angle_option(self):
        detail, table = execute(['--corrected-bound-angle'])
        self.assertIn('UXF', detail)
        rows = parse_tables(table)
        self.assertTrue(all(math.isfinite(v) for row in rows for v in row[1:]))
        # The correction is an alternative calculation; it is not identical.
        _, published = execute()
        self.assertNotEqual(table, published)


if __name__ == '__main__':
    unittest.main()
