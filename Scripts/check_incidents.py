#!/usr/bin/env python3
# Written by release-kit; adapt it to this project freely.
"""Checks docs/incidents.md: every row names commits that exist, a layer from the list
in that file, and a catcher that is really in this repository (a tracked file, or a
name found in the tests, the scripts or the workflows)."""
import pathlib, re, subprocess, sys

LAYERS = {"write-time", "unit", "check", "review", "release-preflight", "hand-test", "field"}
root = pathlib.Path(__file__).resolve().parent.parent


def app_env():
    values = {}
    for line in (root / "app.env").read_text(encoding="utf-8").splitlines():
        match = re.fullmatch(r'([A-Z][A-Z0-9_]*)="([^"\\$`]*)"', line.strip())
        if match:
            values[match[1]] = match[2]
    return values


prefix = re.escape(app_env().get("INCIDENT_PREFIX", "I"))
text = (root / "docs/incidents.md").read_text(encoding="utf-8")


def commit_exists(sha):
    return subprocess.run(["git", "-C", str(root), "cat-file", "-e", sha + "^{commit}"],
                          capture_output=True).returncode == 0


searchable = "".join(path.read_text(encoding="utf-8", errors="ignore")
                     for folder in ("Tests", "Scripts", ".github/workflows")
                     for path in sorted((root / folder).rglob("*")) if path.is_file())

problems, rows = [], 0
for line in text.splitlines():
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    if len(cells) != 7 or not re.fullmatch(prefix + r"-\d+", cells[0]):
        continue
    rows += 1
    ident, _reported, _symptom, introduced, fixed, layer, catcher = cells
    for label, sha in (("introduced", introduced), ("fixed", fixed)):
        if sha in ("", "unknown") and label == "introduced":
            continue
        if not commit_exists(sha):
            problems.append(f"{ident}: {label} commit {sha!r} does not exist")
    if layer not in LAYERS:
        problems.append(f"{ident}: layer {layer!r} is not one of {sorted(LAYERS)}")
    name = catcher.strip("`")
    if not ((root / name).is_file() or name in searchable):
        problems.append(f"{ident}: catcher {name!r} is neither a file nor found in Tests/, Scripts/ or the workflows")

print("\n".join(problems) if problems else f"Incident ledger holds ({rows} row(s)).")
sys.exit(1 if problems else 0)
