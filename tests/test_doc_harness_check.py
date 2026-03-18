from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from scripts.check_doc_harness import (
    discover_core_sources,
    doc_path_for_source,
    run_checks,
)


def write(path: Path, content: str = "") -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


class DocHarnessCheckTests(unittest.TestCase):
    def test_scope_discovery_excludes_tools(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write(root / "Main.lean", "def main := ()\n")
            write(root / "SymbolicLean.lean", "import SymbolicLean.Basic\n")
            write(root / "SymbolicLean/Basic.lean", "def hello := \"world\"\n")
            write(root / ".github/workflows/ci.yml", "name: CI\n")
            write(root / "tools/ignore.txt", "skip\n")

            sources = discover_core_sources(root)
            self.assertIn(Path("SymbolicLean/Basic.lean"), sources)
            self.assertIn(Path("Main.lean"), sources)
            self.assertIn(Path(".github/workflows/ci.yml"), sources)
            self.assertNotIn(Path("tools/ignore.txt"), sources)

    def test_missing_mirror_doc_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write(root / "Main.lean", "def main := ()\n")
            findings = run_checks(root, "core")
            kinds = {finding.kind for finding in findings}
            self.assertIn("missing_mirror_doc", kinds)
            self.assertIn("docs/Main.lean.md", {finding.file for finding in findings})

    def test_orphan_mirror_doc_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write(root / "docs/SymbolicLean/Ghost.lean.md", "# Ghost\n")
            findings = run_checks(root, "core")
            self.assertIn("orphan_mirror_doc", {finding.kind for finding in findings})

    def test_missing_required_sections_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = Path("Main.lean")
            write(root / source, "def main := ()\n")
            write(
                root / doc_path_for_source(source),
                "# `Main.lean`\n\n## Source\n- [x](../Main.lean)\n",
            )
            findings = run_checks(root, "core")
            self.assertIn("missing_required_section", {finding.kind for finding in findings})

    def test_broken_links_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write(root / "docs/index.md", "[broken](missing.md)\n")
            findings = run_checks(root, "core")
            self.assertIn("broken_link", {finding.kind for finding in findings})


if __name__ == "__main__":
    unittest.main()
