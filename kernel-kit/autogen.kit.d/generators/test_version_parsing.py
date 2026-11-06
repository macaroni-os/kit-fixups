#!/usr/bin/env python3
"""Version-handling tests for the kernel sources generator.

The generator accepts both the three-field kernel form (X.Y.Z) and the
two-field mainline form (X.Y). A two-field version must not be rewritten
with a trailing '.0' just to make the parser accept it.
"""

import asyncio
import importlib.util
import pathlib
import unittest


GEN_PATH = pathlib.Path(__file__).with_name('generator_v2.1.py')
SPEC = importlib.util.spec_from_file_location('generator_v2_1', GEN_PATH)
if SPEC is None:
    raise RuntimeError(f'Could not load generator module at {GEN_PATH}')
GEN = importlib.util.module_from_spec(SPEC)
if SPEC.loader is None:
    raise RuntimeError(f'No loader for generator module at {GEN_PATH}')
SPEC.loader.exec_module(GEN)


class FakeResponse:
    def __init__(self, text=''):
        self.text = text

    def raise_for_status(self):
        return None


class VersionParsingTests(unittest.TestCase):
    def test_two_and_three_field_versions(self):
        self.assertEqual(GEN.parse_version_tuple('7.2'), (7, 2, 0, 0))
        self.assertEqual(GEN.parse_version_tuple('7.2.0'), (7, 2, 0, 0))
        self.assertEqual(GEN.parse_version_tuple('7.2.0_p1'), (7, 2, 0, 1))
        self.assertEqual(GEN.parse_version_tuple('6.12.38'), (6, 12, 38, 0))
        self.assertEqual(GEN.parse_version_tuple('6.12.38_p1'), (6, 12, 38, 1))
        self.assertEqual(GEN.parse_version_branch('7.2'), '7.2')
        self.assertEqual(GEN.parse_version_branch('6.1_p2'), '6.1')
        self.assertEqual(GEN.parse_version_branch('6.12.38_p1'), '6.12')

    def test_invalid_version_returns_none(self):
        self.assertIsNone(GEN.parse_version_tuple('7.x'))
        self.assertIsNone(GEN.parse_version_tuple('7'))
        self.assertIsNone(GEN.parse_version_branch('7.x'))

    def test_range_accepts_two_field_versions(self):
        self.assertTrue(GEN.version_in_range('7.2', (7, 0), (7, 3)))
        self.assertTrue(GEN.version_in_range('7.2.0_p1', (7, 0), (7, 3)))
        self.assertFalse(GEN.version_in_range('7.4', (7, 0), (7, 3)))

    def test_debian_package_listing_accepts_two_field_versions(self):
        text = (
            'pool/main/l/linux/linux-source_7.2-1_all.deb\n'
            'pool/main/l/linux/linux-source_6.12.38-1_all.deb'
        )
        self.assertEqual(GEN._parse_linux_source_versions(text), [
            ((7, 2, 0, 1), '7.2', '1'),
            ((6, 12, 38, 1), '6.12.38', '1'),
        ])

    def test_check_version_keeps_two_field_triplet(self):
        rel = ('sid', 'sid')
        result = asyncio.run(GEN.check_version(
            openzfs_compat={}, ver='7.2_p1', rel=rel, track_openzfs=False))
        self.assertEqual(result, ('7.2_p1', '7.2', '1'))

    def test_check_version_rejects_trailing_junk(self):
        with self.assertRaises(ValueError):
            asyncio.run(GEN.check_version(
                openzfs_compat={}, ver='7.2_p1junk',
                rel=('sid', 'sid'), track_openzfs=False))

    def test_find_latest_never_fabricates_dot_zero(self):
        html = (
            '<a href="linux-7.2.tar.xz">linux-7.2.tar.xz</a>'
            '<a href="linux-7.2.1.tar.xz">linux-7.2.1.tar.xz</a>'
        )

        async def fake_request(*args, **kwargs):
            return FakeResponse(html)

        original = getattr(GEN, '_request_with_retry')
        setattr(GEN, '_request_with_retry', fake_request)
        try:
            result = asyncio.run(
                GEN.find_latest_in_branch('7.2', (7, 0), (7, 3), '', ''))
        finally:
            setattr(GEN, '_request_with_retry', original)
        self.assertEqual(result[0], '7.2.1')
        self.assertTrue(result[1])
        self.assertNotIn('.0_p0', str(result))


if __name__ == '__main__':
    unittest.main()
