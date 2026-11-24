"""Repository static checks: JSON notebooks, Python syntax, local Markdown links.

No external packages or private datasets required. This does NOT execute R or ML.
"""
from __future__ import annotations

import ast
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]


def validate() -> list[str]:
    problems: list[str] = []

    for path in ROOT.rglob("*.ipynb"):
        if ".git" in path.parts:
            continue
        try:
            notebook = json.loads(path.read_text(encoding="utf-8"))
            if notebook.get("nbformat") != 4 or not isinstance(notebook.get("cells"), list):
                raise ValueError("Notebook v4のcells配列がありません")
            for i, cell in enumerate(notebook["cells"]):
                if cell.get("cell_type") != "code":
                    continue
                source = cell.get("source", [])
                source_text = "".join(source) if isinstance(source, list) else source
                compile(source_text, str(path) + f" cell {i}", "exec")
        except (ValueError, SyntaxError, OSError, TypeError) as exc:
            problems.append(f"{path.relative_to(ROOT)}: {exc}")

    for path in ROOT.rglob("*.py"):
        if ".git" in path.parts:
            continue
        try:
            ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        except (OSError, SyntaxError, UnicodeError) as exc:
            problems.append(f"{path.relative_to(ROOT)}: {exc}")

    link_pattern = re.compile(r"\]\(([^)]+)\)")
    for path in ROOT.rglob("*.md"):
        if ".git" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        for raw in link_pattern.findall(text):
            url = raw.split("#", 1)[0].strip()
            if not url or url.startswith(("https://", "http://", "mailto:", "/")):
                continue
            target = (path.parent / unquote(url)).resolve()
            if not target.is_relative_to(ROOT) or not target.exists():
                problems.append(f"{path.relative_to(ROOT)}: broken link: {raw}")

    return problems


if __name__ == "__main__":
    issues = validate()
    if issues:
        for issue in issues:
            print("ERROR:", issue, file=sys.stderr)
        raise SystemExit(1)
    print("OK: notebook JSON, Python syntax, and local Markdown links")
