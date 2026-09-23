"""Verify the current distributable against its manifest and source assets."""
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = ROOT / "builds/HotelEmpire-windows-x86_64.zip"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    expected = {"HotelEmpire.exe", "LEIA-ME.txt", "LICENSE-GODOT.txt",
                "THIRD-PARTY-NOTICES.txt", "build-manifest.json"}
    with ZipFile(ARCHIVE) as archive:
        names = archive.namelist()
        assert len(names) == len(expected) and set(names) == expected, "ZIP inventory mismatch"
        manifest = json.loads(archive.read("build-manifest.json").decode("utf-8-sig"))
        executable = archive.read("HotelEmpire.exe")
        assert digest(executable) == manifest["executableSha256"], "Executable hash mismatch"
        assert len(executable) == manifest["executableBytes"], "Executable size mismatch"
        assert manifest["sourceDirty"] is False, "Build was made from a dirty worktree"
        assert manifest["smoke"]["failures"] == 0, "Build smoke failed"
        for name in expected - {"HotelEmpire.exe", "build-manifest.json"}:
            assert archive.read(name) == (ROOT / "docs/release" / name).read_bytes(), f"Stale packaged document: {name}"
    assets = json.loads((ROOT / "docs/art/manifest.json").read_text(encoding="utf-8-sig"))
    paths = [asset["path"] for asset in assets]
    actual = {p.relative_to(ROOT).as_posix() for p in (ROOT / "assets/art").rglob("*.png")}
    assert len(paths) == len(set(paths)) and set(paths) == actual, "Art inventory mismatch"
    for asset in assets:
        data = (ROOT / asset["path"]).read_bytes()
        assert len(data) == asset["bytes"] and digest(data) == asset["sha256"], f"Changed art: {asset['path']}"
    result = {
        "scope": "Local distribution integrity; not external compatibility or commercial clearance",
        "archiveSha256": digest(ARCHIVE.read_bytes()),
        "sourceRevision": manifest["gitRevision"],
        "executableSha256": manifest["executableSha256"],
        "sourceDirtyAtBuild": manifest["sourceDirty"],
        "packagedFiles": sorted(expected),
        "artFilesVerified": len(assets),
        "checks": ["exact ZIP inventory", "executable hash and size", "clean build manifest",
                   "build smoke result", "packaged documents equal source", "complete art inventory and hashes"],
        "limitations": ["External hardware remains untested", "Manual compatibility checklist remains open",
                        "No assertion of signature, installer, store publication or legal clearance"],
    }
    output = ROOT / "docs/release/local-distribution-audit.json"
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
