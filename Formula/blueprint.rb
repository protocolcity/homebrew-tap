# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
# Dual-source (Path B):
#   - Primary (url/sha256): protocolcity/BluePrint tip archive — Source of Truth
#     for Map V1 (map/v1/ tree: serve.py, server/, static/, tests/).
#     BluePrint tip has NO pyproject.toml / setup.py — planted as file tree
#     into libexec, not pip-installed.
#   - Resource "suite": PyPI protocolcity_blueprint 0.1.49 — provides the
#     `blueprint` CLI (setup/serve/service) until the suite BFF mounts V1
#     endpoints. PyPI is NOT the Map SoT.
#
# Version face "0.1.50" is the Cellar face for this Map V1 drop; it is NOT
# a PyPI 0.1.50 cut (no twine to PyPI).
#
# Engines: protocolcity-worklane 0.1.7 + protocolcity-workforce 0.1.7.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#   blueprint-map --binder <dir> --port 8801
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://github.com/protocolcity/BluePrint"
  url "https://github.com/protocolcity/BluePrint/archive/39613f5f8e8aab841d1df84da6e2e4a99beac1af.tar.gz"
  sha256 "3031d84ca7b9059489ff0f7e81a1ea692eb956d503659c5fa1c26dc6de471fe9"
  version "0.1.50"
  license "Apache-2.0"

  depends_on "python@3.11"

  # Suite CLI comes from PyPI 0.1.49 — NOT the Map SoT.
  resource "suite" do
    url "https://files.pythonhosted.org/packages/35/be/4c481b35316ceb6b9814b51e046f16a21db983df007ea65782337d795ed0/protocolcity_blueprint-0.1.49.tar.gz"
    sha256 "f5d482723f2eb2ab20f0b53e511beb0e136e3b78cb321aa313b2850f02aaf404"
  end

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Suite CLI from PyPI resource. BluePrint tip has no packaging metadata,
    # so we do NOT pip_install the buildpath.
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

    # Wrapper: `blueprint-map --binder DIR --port 8801`.
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

      Map V1 (SoT = protocolcity/BluePrint) — dogfood via:

        blueprint-map --binder <your-binder-dir> --port 8801

      Suite CLI (from PyPI 0.1.49) unchanged until the suite BFF mounts V1
      endpoints:

        blueprint setup
        blueprint serve --root <your-workspace>

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
