#!/usr/bin/env python3
"""Update Formula/dotfiles-manager.rb for a stamped upstream release."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


PACKAGE = "github.com/shpoont/dotfiles-manager/internal/app"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--formula", default="Formula/dotfiles-manager.rb")
    parser.add_argument("--version", required=True)
    parser.add_argument("--source-sha256", required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--source-date", required=True)
    parser.add_argument("--channel", required=True)
    parser.add_argument("--provenance", required=True)
    parser.add_argument("--drop-bottle", action="store_true")
    return parser.parse_args()


def validate(args: argparse.Namespace) -> None:
    if args.version.startswith("v") or not args.version:
        raise SystemExit("--version must be the tag without leading v")
    if not re.fullmatch(r"[0-9a-f]{64}", args.source_sha256):
        raise SystemExit("--source-sha256 must be a 64-character lowercase hex SHA256")
    if not re.fullmatch(r"[0-9a-f]{40}", args.source_commit):
        raise SystemExit("--source-commit must be a 40-character lowercase git SHA")
    if not re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z", args.source_date):
        raise SystemExit("--source-date must be a UTC RFC3339 timestamp ending in Z")
    if args.channel not in {"stable", "prerelease", "snapshot"}:
        raise SystemExit("--channel must be stable, prerelease, or snapshot")
    if args.provenance != "homebrew-source":
        raise SystemExit("--provenance must be exactly homebrew-source for dotfiles-manager tap builds")


def replace_one(text: str, pattern: str, replacement: str, description: str, flags: int = 0) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=flags)
    if count != 1:
        raise SystemExit(f"Expected to update exactly one {description}, got {count}")
    return updated


def constants_block(args: argparse.Namespace) -> str:
    return (
        f'  BUILD_COMMIT = "{args.source_commit}"\n'
        f'  BUILD_DATE = "{args.source_date}"\n'
        f'  BUILD_CHANNEL = "{args.channel}"\n'
        f'  BUILD_PROVENANCE = "{args.provenance}"\n'
    )


def install_block() -> str:
    return f'''  def install
    # Build static Go bottles so the executable does not depend on a
    # Homebrew-relocated dynamic loader path.
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X {PACKAGE}.buildVersion=#{{version}}
      -X {PACKAGE}.buildCommit=#{{BUILD_COMMIT}}
      -X {PACKAGE}.buildDate=#{{BUILD_DATE}}
      -X {PACKAGE}.buildChannel=#{{BUILD_CHANNEL}}
      -X {PACKAGE}.buildProvenance=#{{BUILD_PROVENANCE}}
    ].join(" ")
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/dotfiles-manager"
  end'''


def test_block() -> str:
    return '''  test do
    (testpath/".dotfiles-manager.yaml").write <<~YAML
      syncs:
        - target: .config/nvim
          source: .config/nvim
    YAML

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status --json")
    assert_match '"ok":true', output

    version_output = shell_output("#{bin}/dotfiles-manager --version").strip
    assert_match "dotfiles-manager version=#{version}", version_output
    assert_match "commit=#{BUILD_COMMIT}", version_output
    assert_match "date=#{BUILD_DATE}", version_output
    assert_match "channel=#{BUILD_CHANNEL}", version_output
    assert_match "provenance=#{BUILD_PROVENANCE}", version_output
    refute_match "version=dev", version_output
    refute_match "commit=unknown", version_output
    refute_match "date=unknown", version_output
    refute_match "channel=dev", version_output
    refute_match "provenance=unspecified", version_output
  end'''


def update_formula(args: argparse.Namespace) -> None:
    path = Path(args.formula)
    text = path.read_text()

    text = replace_one(
        text,
        r'^\s*url\s+"https://github\.com/shpoont/dotfiles-manager/archive/refs/tags/v[^"]+\.tar\.gz"\s*$',
        f'  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v{args.version}.tar.gz"',
        "source url line",
        flags=re.M,
    )
    text = replace_one(
        text,
        r'^\s*sha256\s+"[0-9a-f]{64}"\s*$',
        f'  sha256 "{args.source_sha256}"',
        "source sha line",
        flags=re.M,
    )

    if args.drop_bottle:
        text = re.sub(r'\n  bottle do\n.*?\n  end\n', '\n', text, count=1, flags=re.S)

    existing_constants = re.compile(
        r'\n  BUILD_COMMIT = "[0-9a-f]{40}"\n'
        r'  BUILD_DATE = "[^"]+"\n'
        r'  BUILD_CHANNEL = "[^"]+"\n'
        r'  BUILD_PROVENANCE = "[^"]+"\n',
        re.M,
    )
    block = "\n\n" + constants_block(args)
    if existing_constants.search(text):
        text = existing_constants.sub(block, text, count=1)
    else:
        text = replace_one(
            text,
            r'(^\s*sha256\s+"[0-9a-f]{64}"\s*$)',
            r'\1' + block.rstrip("\n"),
            "metadata constants insertion point",
            flags=re.M,
        )

    text = replace_one(
        text,
        r'  def install\n.*?\n  end',
        install_block(),
        "install block",
        flags=re.S,
    )
    text = replace_one(
        text,
        r'  test do\n.*?\n  end',
        test_block(),
        "test block",
        flags=re.S,
    )

    while "\n\n\n" in text:
        text = text.replace("\n\n\n", "\n\n")
    path.write_text(text)


def main() -> None:
    args = parse_args()
    validate(args)
    update_formula(args)


if __name__ == "__main__":
    main()
