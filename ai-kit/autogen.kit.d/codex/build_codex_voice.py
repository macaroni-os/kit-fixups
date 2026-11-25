#!/usr/bin/env python3
"""Build and package the voice helper against system GStreamer on Python 3.9."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess


MODULES = (
    "gstreamer-1.0", "gstreamer-base-1.0", "gstreamer-app-1.0",
    "gstreamer-audio-1.0",
)


def digest(path):
    hasher = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("source", "package", "output"):
        parser.add_argument("--" + name, type=Path, required=True)
    for name in ("target", "commit", "version", "pkg-config", "strip"):
        parser.add_argument("--" + name, required=True)
    args = parser.parse_args()
    metadata = json.loads((args.package / "codex-package.json").read_text())
    if metadata["target"] != args.target or metadata["version"] != args.version:
        parser.error("base package version or target does not match the voice build")
    versions = {}
    for module in MODULES:
        subprocess.run([args.pkg_config, "--atleast-version=1.26", module], check=True)
        versions[module] = subprocess.check_output(
            [args.pkg_config, "--modversion", module], text=True,
        ).strip()

    voice_env = {**os.environ, "PKG_CONFIG": args.pkg_config}
    subprocess.run(
        ["cargo", "build", "--release", "--target", args.target,
         "-p", "codex-voice-host", "--bin", "codex-voice-host"],
        cwd=args.source / "codex-rs", env=voice_env, check=True,
    )
    helper = Path(os.environ["CARGO_TARGET_DIR"]) / args.target / "release/codex-voice-host"
    subprocess.run([args.strip, "--strip-unneeded", str(helper)], check=True)

    package_voice(args, helper, versions)


def package_voice(args, helper, versions):
    # Only replace this build's output after the helper has built successfully.
    output = args.output.absolute()
    if output.is_symlink() or args.package.resolve().is_relative_to(output.resolve()):
        parser.error("voice output must be separate from the input package")
    if output.exists():
        shutil.rmtree(output)
    shutil.copytree(args.package, output)
    voice = output / "codex-resources/voice"
    (voice / "bin").mkdir(parents=True)
    shutil.copy2(helper, voice / "bin/codex-voice-host")
    runtime = {
        "schemaVersion": 1,
        "kind": "system",
        "target": args.target,
        "buildVersions": versions,
        "coreLibrary": os.environ["CODEX_SYSTEM_GSTREAMER_CORE"],
        "pluginDirectory": os.environ["CODEX_SYSTEM_GSTREAMER_PLUGIN_DIR"],
    }
    (voice / "runtime.json").write_text(json.dumps(runtime, indent=2) + "\n")
    (voice / "NOTICE.md").write_text(
        "This build uses system GStreamer, GLib and Opus libraries and plugins.\n"
        "Their packages provide the native libraries and associated licenses.\n"
        "Build-time module versions and locations are recorded in runtime.json.\n"
    )
    files = ("bin/codex", "codex-resources/voice/bin/codex-voice-host",
             "codex-resources/voice/runtime.json", "codex-resources/voice/NOTICE.md")
    manifest = {
        "schemaVersion": 1,
        "buildCommit": args.commit,
        "appTarget": args.target,
        "voiceTarget": args.target,
        "appVersion": args.version,
        "sha256": {name: digest(output / name) for name in files},
    }
    (voice / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
