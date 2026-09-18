#!/usr/bin/env python3
"""Source + plist-root tests for Formula/blueprint.rb (pc-1565 / tap#19)."""

from __future__ import annotations

import re
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORMULA = (ROOT / "Formula" / "blueprint.rb").read_text()


def extract_root_from_plist_xml(xml: str | None) -> str | None:
    """Mirror Blueprint.extract_root_from_plist_xml (keep in lockstep)."""
    if not xml:
        return None
    for flag in ("--root", "--binder"):
        match = re.search(
            rf"<string>{re.escape(flag)}</string>\s*<string>([^<]+)</string>",
            xml,
        )
        if match and match.group(1).strip():
            return match.group(1).strip()
    match = re.search(r"<key>SUITE_CITY_ROOT</key>\s*<string>([^<]+)</string>", xml)
    if match and match.group(1).strip():
        return match.group(1).strip()
    match = re.search(r"<key>WorkingDirectory</key>\s*<string>([^<]+)</string>", xml)
    if match and match.group(1).strip():
        return match.group(1).strip()
    return None


def discover_workspace_root(*, home: Path, env: dict[str, str] | None = None) -> str | None:
    env = env or {}
    env_root = (env.get("SUITE_CITY_ROOT") or "").strip()
    if env_root and Path(env_root).expanduser().is_dir():
        return str(Path(env_root).expanduser().resolve())

    state = home / ".protocolcity" / "service.json"
    if state.is_file():
        import json

        try:
            raw = str(json.loads(state.read_text()).get("root") or "").strip()
        except json.JSONDecodeError:
            raw = ""
        if raw and Path(raw).expanduser().is_dir():
            return str(Path(raw).expanduser().resolve())

    labels = (
        "com.protocolcity.suite",
        "com.protocolcity.blueprint-overview",
        "com.protocolcity.blueprint-map",
    )
    agents = home / "Library" / "LaunchAgents"
    for label in labels:
        plist = agents / f"{label}.plist"
        if not plist.is_file():
            continue
        found = extract_root_from_plist_xml(plist.read_text())
        if found and Path(found).expanduser().is_dir():
            return str(Path(found).expanduser().resolve())
    return None


class FormulaSourceTests(unittest.TestCase):
    def test_does_not_call_upgrade_without_root(self) -> None:
        self.assertNotRegex(
            FORMULA,
            r'system bin/"blueprint", "upgrade", "--quiet"',
        )
        self.assertIn(
            'system bin/"blueprint", "upgrade", "--root", root, "--quiet"',
            FORMULA,
        )

    def test_skips_when_root_missing(self) -> None:
        self.assertIn("post_install skipped", FORMULA)
        self.assertIn("discover_workspace_root", FORMULA)
        self.assertIn("com.protocolcity.suite", FORMULA)
        self.assertIn("com.protocolcity.blueprint-overview", FORMULA)
        self.assertIn("--binder", FORMULA)

    def test_caveats_are_honest_and_hold_8801(self) -> None:
        caveats = FORMULA.split("def caveats", 1)[1]
        self.assertIn(":8801", caveats)
        self.assertIn("suite Map HARD HOLD", caveats)
        self.assertIn("blueprint upgrade --root <your-workspace>", caveats)
        self.assertNotIn("One origin only:", caveats)
        self.assertNotIn(
            "post_install runs `blueprint upgrade --quiet`",
            caveats,
        )
        # Do not reopen the stale :8803-only caveats from tap#17.
        self.assertNotIn("single port :8803 only", FORMULA)

    def test_cites_pc_1565_and_tap_19(self) -> None:
        self.assertIn("pc-1565", FORMULA)
        self.assertIn("homebrew-tap#19", FORMULA)
        self.assertIn("revision 1", FORMULA)

    def test_ruby_extractor_matches_python_mirror(self) -> None:
        self.assertIn("def self.extract_root_from_plist_xml(xml)", FORMULA)
        self.assertIn("--root", FORMULA)
        self.assertIn("--binder", FORMULA)
        self.assertIn("SUITE_CITY_ROOT", FORMULA)
        self.assertIn("WorkingDirectory", FORMULA)


class PlistRootTests(unittest.TestCase):
    def test_program_arguments_root(self) -> None:
        xml = """
        <array>
          <string>blueprint</string>
          <string>serve</string>
          <string>--root</string>
          <string>/Users/elseo/Projects</string>
        </array>
        """
        self.assertEqual(extract_root_from_plist_xml(xml), "/Users/elseo/Projects")

    def test_binder_when_root_absent(self) -> None:
        xml = """
        <array>
          <string>blueprint-overview</string>
          <string>--binder</string>
          <string>/Users/elseo/OneSeo</string>
          <string>--port</string>
          <string>8803</string>
        </array>
        """
        self.assertEqual(extract_root_from_plist_xml(xml), "/Users/elseo/OneSeo")

    def test_root_wins_over_binder(self) -> None:
        xml = """
        <array>
          <string>blueprint</string>
          <string>serve</string>
          <string>--root</string>
          <string>/Users/elseo/Projects</string>
          <string>--binder</string>
          <string>/Users/elseo/OneSeo</string>
        </array>
        """
        self.assertEqual(extract_root_from_plist_xml(xml), "/Users/elseo/Projects")

    def test_env_and_working_directory_fallbacks(self) -> None:
        env_xml = "<key>SUITE_CITY_ROOT</key>\n<string>/opt/desk</string>"
        self.assertEqual(extract_root_from_plist_xml(env_xml), "/opt/desk")
        wd_xml = "<key>WorkingDirectory</key>\n<string>/opt/wd</string>"
        self.assertEqual(extract_root_from_plist_xml(wd_xml), "/opt/wd")

    def test_empty_xml_is_none(self) -> None:
        self.assertIsNone(extract_root_from_plist_xml(""))
        self.assertIsNone(extract_root_from_plist_xml(None))
        self.assertIsNone(extract_root_from_plist_xml("<plist></plist>"))


class DiscoverHomeTests(unittest.TestCase):
    def test_skip_when_nothing_recorded(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            self.assertIsNone(discover_workspace_root(home=Path(tmp), env={}))

    def test_suite_plist_root(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            workspace = home / "Projects"
            workspace.mkdir()
            agents = home / "Library" / "LaunchAgents"
            agents.mkdir(parents=True)
            (agents / "com.protocolcity.suite.plist").write_text(
                f"""<?xml version="1.0"?>
                <plist><dict>
                  <key>ProgramArguments</key>
                  <array>
                    <string>serve</string>
                    <string>--root</string>
                    <string>{workspace}</string>
                  </array>
                </dict></plist>
                """
            )
            self.assertEqual(
                discover_workspace_root(home=home, env={}),
                str(workspace.resolve()),
            )

    def test_overview_binder_when_suite_absent(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            binder = home / "OneSeo"
            binder.mkdir()
            agents = home / "Library" / "LaunchAgents"
            agents.mkdir(parents=True)
            (agents / "com.protocolcity.blueprint-overview.plist").write_text(
                f"""<?xml version="1.0"?>
                <plist><dict>
                  <key>ProgramArguments</key>
                  <array>
                    <string>--binder</string>
                    <string>{binder}</string>
                  </array>
                </dict></plist>
                """
            )
            self.assertEqual(
                discover_workspace_root(home=home, env={}),
                str(binder.resolve()),
            )

    def test_suite_wins_over_overview(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            suite_root = home / "Projects"
            overview_root = home / "OneSeo"
            suite_root.mkdir()
            overview_root.mkdir()
            agents = home / "Library" / "LaunchAgents"
            agents.mkdir(parents=True)
            (agents / "com.protocolcity.suite.plist").write_text(
                f"<string>--root</string><string>{suite_root}</string>"
            )
            (agents / "com.protocolcity.blueprint-overview.plist").write_text(
                f"<string>--binder</string><string>{overview_root}</string>"
            )
            self.assertEqual(
                discover_workspace_root(home=home, env={}),
                str(suite_root.resolve()),
            )

    def test_service_json_and_env(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            recorded = home / "CSS"
            recorded.mkdir()
            state = home / ".protocolcity"
            state.mkdir()
            (state / "service.json").write_text(f'{{"root": "{recorded}"}}')
            self.assertEqual(
                discover_workspace_root(home=home, env={}),
                str(recorded.resolve()),
            )
            env_root = home / "from-env"
            env_root.mkdir()
            self.assertEqual(
                discover_workspace_root(
                    home=home, env={"SUITE_CITY_ROOT": str(env_root)}
                ),
                str(env_root.resolve()),
            )

    def test_missing_recorded_path_is_skipped(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            agents = home / "Library" / "LaunchAgents"
            agents.mkdir(parents=True)
            (agents / "com.protocolcity.suite.plist").write_text(
                "<string>--root</string><string>/definitely/missing/workspace</string>"
            )
            self.assertIsNone(discover_workspace_root(home=home, env={}))


if __name__ == "__main__":
    unittest.main()
