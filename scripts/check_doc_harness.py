#!/usr/bin/env python3
"""Validate docs-harness contracts for this repository."""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

CORE_TOP_LEVEL_FILES = {
    "Main.lean",
    "SymbolicLean.lean",
    "lakefile.toml",
    "lean-toolchain",
    "lake-manifest.json",
}
CORE_DIR_PREFIXES = {
    Path("SymbolicLean"),
    Path(".github/workflows"),
}
DOC_ROOT = Path("docs")
REQUIRED_SECTION_HEADINGS = {
    "Source",
    "Responsibilities",
    "Public Surface",
    "Change Triggers",
    "Related Files",
}

LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^##\s+(.+?)\s*$")


@dataclass(frozen=True)
class Finding:
    kind: str
    message: str
    file: str
    line: int = 1


def is_within(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def is_core_source_path(source_rel: Path) -> bool:
    source_rel = Path(source_rel)
    if source_rel.as_posix() in CORE_TOP_LEVEL_FILES:
        return True
    return any(is_within(source_rel, prefix) for prefix in CORE_DIR_PREFIXES)


def discover_core_sources(repo_root: Path) -> set[Path]:
    sources: set[Path] = set()
    for file_name in CORE_TOP_LEVEL_FILES:
        source = repo_root / file_name
        if source.is_file():
            sources.add(Path(file_name))
    for prefix in CORE_DIR_PREFIXES:
        root = repo_root / prefix
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file():
                sources.add(path.relative_to(repo_root))
    return sources


def doc_path_for_source(source_rel: Path) -> Path:
    return DOC_ROOT / f"{source_rel.as_posix()}.md"


def source_path_from_doc(doc_rel: Path) -> Path | None:
    if doc_rel.suffix != ".md":
        return None
    rel_to_docs = doc_rel.relative_to(DOC_ROOT)
    return Path(rel_to_docs.as_posix()[: -len(".md")])


def collect_doc_files(repo_root: Path) -> set[Path]:
    docs_root = repo_root / DOC_ROOT
    if not docs_root.exists():
        return set()
    return {path.relative_to(repo_root) for path in docs_root.rglob("*.md")}


def check_missing_docs(expected_docs: set[Path], existing_docs: set[Path]) -> list[Finding]:
    findings = []
    for doc in sorted(expected_docs - existing_docs):
        source = source_path_from_doc(doc)
        findings.append(
            Finding(
                kind="missing_mirror_doc",
                message=f"Missing mirrored doc for `{source.as_posix()}`",
                file=doc.as_posix(),
            )
        )
    return findings


def check_orphan_docs(core_sources: set[Path], existing_docs: set[Path]) -> list[Finding]:
    findings = []
    for doc in sorted(existing_docs):
        source = source_path_from_doc(doc)
        if source is None or not is_core_source_path(source):
            continue
        if source not in core_sources:
            findings.append(
                Finding(
                    kind="orphan_mirror_doc",
                    message=f"Mirrored doc has no source file in scope: `{source.as_posix()}`",
                    file=doc.as_posix(),
                )
            )
    return findings


def read_level2_headings(markdown: str) -> set[str]:
    headings = set()
    for line in markdown.splitlines():
        match = HEADING_RE.match(line)
        if match:
            headings.add(match.group(1).strip())
    return headings


def check_required_sections(repo_root: Path, docs_to_check: Iterable[Path]) -> list[Finding]:
    findings = []
    for doc in sorted(docs_to_check):
        content = (repo_root / doc).read_text(encoding="utf-8")
        headings = read_level2_headings(content)
        missing = sorted(REQUIRED_SECTION_HEADINGS - headings)
        if missing:
            findings.append(
                Finding(
                    kind="missing_required_section",
                    message=f"Missing required sections: {', '.join(missing)}",
                    file=doc.as_posix(),
                )
            )
    return findings


def check_broken_links(repo_root: Path, all_docs: Iterable[Path]) -> list[Finding]:
    findings = []
    for doc in sorted(all_docs):
        doc_abs = repo_root / doc
        for line_no, line in enumerate(doc_abs.read_text(encoding="utf-8").splitlines(), start=1):
            for match in LINK_RE.finditer(line):
                target = match.group(1).strip()
                if not target:
                    continue
                if target.startswith("#"):
                    continue
                if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target):
                    continue
                target_path = target.split("#", maxsplit=1)[0]
                if not target_path:
                    continue
                resolved = (doc_abs.parent / target_path).resolve()
                if not resolved.exists():
                    findings.append(
                        Finding(
                            kind="broken_link",
                            message=f"Broken link target `{target}`",
                            file=doc.as_posix(),
                            line=line_no,
                        )
                    )
    return findings


def run_checks(repo_root: Path, scope: str) -> list[Finding]:
    if scope != "core":
        raise ValueError(f"Unsupported scope: {scope}")

    core_sources = discover_core_sources(repo_root)
    expected_docs = {doc_path_for_source(source) for source in core_sources}
    existing_docs = collect_doc_files(repo_root)
    mirrored_docs = expected_docs & existing_docs

    findings: list[Finding] = []
    findings.extend(check_missing_docs(expected_docs, existing_docs))
    findings.extend(check_orphan_docs(core_sources, existing_docs))
    findings.extend(check_required_sections(repo_root, mirrored_docs))
    findings.extend(check_broken_links(repo_root, existing_docs))
    return findings


def emit_local(findings: list[Finding]) -> None:
    if not findings:
        print("doc-harness: no issues found")
        return
    print(f"doc-harness: {len(findings)} issue(s)")
    for finding in findings:
        print(f"- [{finding.kind}] {finding.file}:{finding.line} {finding.message}")


def emit_ci(findings: list[Finding]) -> None:
    if not findings:
        print("doc-harness: no issues found")
        summary = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary:
            Path(summary).write_text("## Doc Harness\n\nNo issues found.\n", encoding="utf-8")
        return

    for finding in findings:
        print(f"::warning file={finding.file},line={finding.line}::{finding.kind}: {finding.message}")
    print(f"doc-harness: {len(findings)} warning(s)")

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        lines = [
            "## Doc Harness",
            "",
            f"Found {len(findings)} warning(s):",
            "",
        ]
        for finding in findings:
            lines.append(f"- `{finding.kind}` in `{finding.file}:{finding.line}`: {finding.message}")
        Path(summary).write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate docs-harness contracts.")
    parser.add_argument("--mode", choices=("local", "ci"), default="local")
    parser.add_argument("--scope", choices=("core",), default="core")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail with exit code 1 when findings are present regardless of mode.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    findings = run_checks(repo_root, args.scope)

    if args.mode == "ci":
        emit_ci(findings)
    else:
        emit_local(findings)

    fail_on_findings = args.strict or args.mode == "local"
    if fail_on_findings and findings:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
