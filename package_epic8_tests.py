"""Collect both Epic 8 testers' files and build the two submission archives."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parent
INPUTS = ROOT / "TestInputs"
OUTPUTS = ROOT / "TestOutputs"
TESTER1 = ROOT / "test-cases" / "epic8-tester1"


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(source.read_bytes())


def archive_folder(folder: Path, archive_path: Path) -> None:
    with ZipFile(archive_path, "w") as archive:
        for source in sorted(folder.rglob("*")):
            if not source.is_file():
                continue
            name = source.relative_to(ROOT).as_posix()
            entry = ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            archive.writestr(entry, source.read_bytes())


for case_dir in sorted(TESTER1.glob("T??")):
    case_id = case_dir.name
    case_input = case_dir / "InCollege-Input.txt"
    if not case_input.exists():
        continue  # T18 inspects stored records and has no program input.

    copy_file(case_input, INPUTS / f"{case_id}-Input.txt")
    copy_file(case_dir / f"{case_id}.out", OUTPUTS / f"{case_id}-Output.txt")

    for name in ("accounts.txt", "connections.txt"):
        fixture = case_dir / name
        if not fixture.exists():
            fixture = ROOT / name
        copy_file(fixture, INPUTS / "Fixtures" / f"{case_id}-{name}")

copy_file(
    TESTER1 / "T14" / "T14-messages-after.snapshot",
    INPUTS / "Fixtures" / "T15-messages.txt",
)

for evidence in sorted((TESTER1 / "T18").iterdir()):
    copy_file(evidence, OUTPUTS / "Evidence" / evidence.name)

archive_folder(INPUTS, ROOT / "Epic8-Storyx-Test-Input.zip")
archive_folder(OUTPUTS, ROOT / "Epic8-Storyx-Test-Output.zip")

print("Packaged 21 executable cases and T18 evidence in separate input/output folders.")
