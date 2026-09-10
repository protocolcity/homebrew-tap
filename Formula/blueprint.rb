# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
# Dual-source (Path B):
#   - Primary (url/sha256): protocolcity/BluePrint tip archive — Source of Truth
#     for Map V1 (map/v1/ tree: serve.py, server/, static/, tests/), served
#     locally by `blueprint-map` on :8802.
#     BluePrint tip has NO pyproject.toml / setup.py — planted as file tree
#     into libexec, not pip-installed.
#   - Resource "suite": PyPI protocolcity_blueprint 0.1.47 — pinned for daily
#     dogfood of the Map/desk feel through `blueprint serve` on :8801. Suite
#     CLI (setup/serve/service) comes from this PyPI cut until the suite BFF
#     mounts V1 endpoints. PyPI is NOT the Map SoT.
#   - Overview MC Spec / inventory docs are unaffected by this pin.
#
# Version face "0.1.50" is the Cellar face for this Map V1 drop; it is NOT
# a PyPI 0.1.50 cut (no twine to PyPI). Revision 3 = suite pinned to 0.1.47.
#
# Engines: protocolcity-worklane 0.1.7 + protocolcity-workforce 0.1.7.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#   blueprint serve --root <your-workspace>       # daily dogfood on :8801
#   blueprint-map --binder <dir> --port 8802      # Map V1 SoT on :8802
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://github.com/protocolcity/BluePrint"
  url "https://github.com/protocolcity/BluePrint/archive/31353986a5a4883aca4461cae69cf80782f95c77.tar.gz"
  sha256 "4991ee53776b95f0c8a6d6c2f3f3638cfaacd83a9eb07c1fe4193b274ef561e5"
  version "0.1.50"
  # Hub collision tip 31353986a5a4883aca4461cae69cf80782f95c77 (BluePrint #40 merged).
  # Revision 3: suite resource pinned to PyPI 0.1.47 for daily :8801 dogfood.
  # Map V1 tip (primary url/sha256) unchanged — still the Map SoT via :8802.
  revision 3
  license "Apache-2.0"

  depends_on "python@3.11"

  # Suite CLI pinned to PyPI 0.1.47 — daily dogfood of Map/desk feel through
  # `blueprint serve` on :8801. NOT the Map SoT (Map V1 SoT is the BluePrint
  # tip planted below and served by `blueprint-map` on :8802).
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

    # Plant Map V1 tree from BluePrint tip (SoT).
    (libexec/"map/v1").mkpath
    cp_r "#{buildpath}/map/v1/.", libexec/"map/v1"

    # Wrapper: `blueprint-map --binder DIR --port 8802`.
    python = Formula["python@3.11"].opt_bin/"python3.11"
    (bin/"blueprint-map").write <<~SH
      #!/bin/bash
      exec "#{python}" "#{libexec}/map/v1/serve.py" "$@"
    SH
    chmod 0755, bin/"blueprint-map"
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
    help = `#{bin}/blueprint-map --help 2>&1`
    assert_match(/binder|serve/i, help)
    assert_match "setup", shell_output("#{bin}/blueprint setup --help")
    assert_match "service", shell_output("#{bin}/blueprint service --help")
    refute_predicate bin/"protocolcity", :exist?
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      BluePrint suite installed (Path B: Map V1 from protocolcity/BluePrint tip).

      Daily dogfood — suite CLI from PyPI 0.1.47 on :8801:

        blueprint setup
        blueprint serve --root <your-workspace>          # :8801

      Map V1 (SoT = protocolcity/BluePrint tip) — served by blueprint-map
      on :8802:

        blueprint-map --binder <your-binder-dir> --port 8802

      Suite CLI is pinned to PyPI 0.1.47 until the suite BFF mounts V1
      endpoints. Overview MC Spec / inventory docs are unaffected.

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
