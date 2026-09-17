# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
#
# PyPI protocolcity-blueprint 0.1.50 sdist filled from cut receipt
# (pc-1468 / BluePrint #145, tap #17 / pc-1518). Still DRAFT — do not merge
# until Security Advisor clear + Delivery ready.
#
# Pins (this PR):
#   - suite / Cellar face: 0.1.50 (PyPI sdist url/sha filled)
#   - tip SoT: BluePrint archive @ 7e9574445f98ba4027b0089027010d4c6b0240c7
#   - engines: protocolcity-worklane==0.1.9 + protocolcity-workforce==0.1.9
#
# post_install: `blueprint upgrade --quiet` (best-effort).
# Caveats: single port :8803 only.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#   blueprint serve --root <your-workspace>    # :8803
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://github.com/protocolcity/BluePrint"
  # Formula SoT = cut tip archive for PyPI 0.1.50 (BluePrint #145 / cut tip).
  url "https://github.com/protocolcity/BluePrint/archive/7e9574445f98ba4027b0089027010d4c6b0240c7.tar.gz"
  sha256 "df6d79b88d8d6567186e6081511ade01780609d81b2df771ad18480e9eebc9a6"
  version "0.1.50"
  license "Apache-2.0"

  depends_on "python@3.11"

  # PyPI suite pin 0.1.50 — sdist from cut receipt / PyPI JSON.
  resource "suite" do
    url "https://files.pythonhosted.org/packages/source/p/protocolcity-blueprint/protocolcity_blueprint-0.1.50.tar.gz"
    sha256 "c0e4eb04d490ea9422e5a843a53fdddfe9919d2be28fdf7bd1c37269d9199d16"
  end

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Suite CLI + surfaces from the PyPI 0.1.50 pin (same cut as tip SoT).
    venv.pip_install_and_link resource("suite")

    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.9",
           "protocolcity-workforce==0.1.9"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
    # Drop legacy console-script name if an older wheel still shipped it.
    rm_f bin/"protocolcity"
  end

  # Best-effort: migrate a prior three-lane Cellar install to the single
  # :8803 app. No workspace is known at brew time; failures are ignored.
  def post_install
    system bin/"blueprint", "upgrade", "--quiet"
  rescue
    nil
  end

  test do
    assert_match "setup", shell_output("#{bin}/blueprint setup --help")
    upgrade_help = `#{bin}/blueprint upgrade --help 2>&1`
    assert_match(/upgrade/i, upgrade_help)
    refute_predicate bin/"protocolcity", :exist?
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      BluePrint suite 0.1.50 is installed (engines 0.1.9). One origin only:

        :8803  blueprint serve --root <your-workspace>

      Next — create or adopt a workspace:

        blueprint setup
        blueprint serve --root <your-workspace>

      Keep running after you close the terminal (macOS login LaunchAgent):

        blueprint service install --root <your-workspace>

      After brew upgrade/install, post_install runs `blueprint upgrade --quiet`.
      Restore always-on:

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
