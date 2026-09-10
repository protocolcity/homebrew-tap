# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
# Dual-source (Path B — three lanes):
#   - Primary (url/sha256): protocolcity/BluePrint tip archive — Source of Truth
#     for BOTH Map V1 (map/v1/ tree) AND Overview V1 (overview/v1/ tree).
#       * `blueprint-map` serves Map V1 on :8802.
#       * `blueprint-overview` serves Overview V1 Mission Control on :8803.
#     BluePrint tip has NO pyproject.toml / setup.py — planted as file trees
#     into libexec, not pip-installed.
#   - Resource "suite": PyPI protocolcity_blueprint 0.1.47 — HARD HOLD pin for
#     daily dogfood of the Map/desk feel through `blueprint serve` on :8801.
#     Suite CLI (setup/serve/service) comes from this PyPI cut until the suite
#     BFF mounts V1 endpoints. PyPI is NOT the Map/Overview SoT.
#   - Overview MC Spec / inventory docs are unaffected by this pin.
#
# Version face "0.1.50" is the Cellar face for this Map+Overview V1 drop; it is
# NOT a PyPI 0.1.50 cut (no twine to PyPI). Revision 6 = Overview #43 tip
# (focusable tiles + silent empty pulse) @ c35db4f5; Map tip included from the
# same archive. Suite resource still pinned to PyPI 0.1.47 (HARD HOLD, :8801
# feel).
#
# Engines: protocolcity-worklane 0.1.7 + protocolcity-workforce 0.1.7.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#   blueprint serve --root <your-workspace>       # daily dogfood on :8801
#   blueprint-map --binder <dir> --port 8802      # Map V1 SoT on :8802
#   blueprint-overview                            # Overview V1 MC on :8803
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://github.com/protocolcity/BluePrint"
  url "https://github.com/protocolcity/BluePrint/archive/c35db4f5d7c4eb990dc3d80bc1693dc7f18e43ff.tar.gz"
  sha256 "de42c1eafe3472bf462da0ed651609d40e6e82cb6ad152af5b0e5ed7d780c71a"
  version "0.1.50"
  # BluePrint #43 Overview focusable tiles + silent empty pulse @ c35db4f5;
  # Map tip included. Revision 6: Overview tip polish only.
  # Suite resource still pinned to PyPI 0.1.47 for daily :8801 dogfood.
  revision 6
  license "Apache-2.0"

  depends_on "python@3.11"

  # Suite CLI pinned to PyPI 0.1.47 — HARD HOLD for daily dogfood of Map/desk
  # feel through `blueprint serve` on :8801. NOT the Map/Overview SoT (V1 SoT
  # is the BluePrint tip planted below and served by `blueprint-map` on :8802
  # and `blueprint-overview` on :8803).
  # Overview MC Spec / inventory docs are unaffected by this pin.
  resource "suite" do
    url "https://files.pythonhosted.org/packages/e6/84/2a2729075e82439831d6933b720899fee3508b7b5e33977db01aa6b1ffd6/protocolcity_blueprint-0.1.47.tar.gz"
    sha256 "aeb33f8e3406c48701558d758b33f40a3d34d7c14e8eccd1a3252b05fc42b307"
  end

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Suite CLI from PyPI 0.1.47 resource (pinned for daily :8801 dogfood).
    # BluePrint tip has no packaging metadata, so we do NOT pip_install the
    # buildpath.
    venv.pip_install_and_link resource("suite")

    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.7",
           "protocolcity-workforce==0.1.7"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
    # Drop legacy console-script name if an older wheel still shipped it.
    rm_f bin/"protocolcity"

    # Plant Map V1 tree from BluePrint tip (SoT). Served on :8802.
    (libexec/"map/v1").mkpath
    cp_r "#{buildpath}/map/v1/.", libexec/"map/v1"

    # Plant Overview V1 tree from BluePrint tip (SoT). Served on :8803.
    (libexec/"overview/v1").mkpath
    cp_r "#{buildpath}/overview/v1/.", libexec/"overview/v1"

    python = Formula["python@3.11"].opt_bin/"python3.11"

    # Wrapper: `blueprint-map --binder DIR --port 8802`.
    (bin/"blueprint-map").write <<~SH
      #!/bin/bash
      exec "#{python}" "#{libexec}/map/v1/serve.py" "$@"
    SH
    chmod 0755, bin/"blueprint-map"

    # Wrapper: `blueprint-overview` (default port 8803 from serve.py).
    (bin/"blueprint-overview").write <<~SH
      #!/bin/bash
      exec "#{python}" "#{libexec}/overview/v1/serve.py" "$@"
    SH
    chmod 0755, bin/"blueprint-overview"
  end

  # Best-effort stop of suite/engines so brew upgrade does not leave
  # an orphan process serving a deleted Cellar path (blank 404 on all routes).
  def post_install
    system bin/"blueprint", "stop", "--quiet"
  rescue
    nil
  end

  test do
    assert_predicate libexec/"map/v1/serve.py", :exist?
    assert_predicate libexec/"overview/v1/serve.py", :exist?
    help = `#{bin}/blueprint-map --help 2>&1`
    assert_match(/binder|serve/i, help)
    overview_help = `#{bin}/blueprint-overview --help 2>&1`
    assert_match(/port|serve|overview/i, overview_help)
    assert_match "setup", shell_output("#{bin}/blueprint setup --help")
    assert_match "service", shell_output("#{bin}/blueprint service --help")
    refute_predicate bin/"protocolcity", :exist?
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      BluePrint suite installed (Path B: three-lane Map+Overview V1 from
      protocolcity/BluePrint tip; suite CLI held at PyPI 0.1.47).

      Three lanes:

        :8801  blueprint serve         — suite CLI from PyPI 0.1.47 (daily HOLD)
        :8802  blueprint-map           — Map V1 from BluePrint tip
        :8803  blueprint-overview      — Overview V1 Mission Control from tip

      Daily dogfood — suite CLI from PyPI 0.1.47 on :8801:

        blueprint setup
        blueprint serve --root <your-workspace>          # :8801

      Map V1 (SoT = protocolcity/BluePrint tip) — served by blueprint-map
      on :8802:

        blueprint-map --binder <your-binder-dir> --port 8802

      Overview V1 Mission Control (SoT = protocolcity/BluePrint tip) — served
      by blueprint-overview on :8803:

        blueprint-overview

      Suite CLI is pinned to PyPI 0.1.47 until the suite BFF mounts V1
      endpoints. No suite BFF mount yet. Overview MC Spec / inventory docs
      are unaffected.

      Keep running after you close the terminal (macOS login LaunchAgent):

        blueprint service install --root <your-workspace>

      After brew upgrade/install, post_install runs `blueprint stop`, which
      unloads the suite (and login agent) so a deleted Cellar path is not
      kept alive. Restore always-on:

        blueprint service start
        # if you never installed the agent:
        blueprint service install --root <your-workspace>
        # one-shot (no login agent):
        blueprint serve --root <your-workspace>

      Remove (stops suite/engines, then keep or delete workspace files):

        blueprint uninstall --app
    EOS
  end
end
