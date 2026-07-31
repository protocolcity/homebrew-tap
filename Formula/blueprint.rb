# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
# PyPI distro name remains protocolcity until protocolcity-blueprint dual-publish.
# Engines: protocolcity-worklane 0.1.5 + protocolcity-workforce 0.1.5.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/b7/2d/90c0788638974f7231757a67f6fcab418df3e9e735920ed450a811168c96/protocolcity-0.1.34.tar.gz"
  sha256 "ade9b82aebc8b2eb166808cd682228380e35f5a2bc911abe2ec24d9e6291548a"
  license "Apache-2.0"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.5",
           "protocolcity-workforce==0.1.5"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
    # Drop legacy console-script name if an older wheel still shipped it.
    rm_f bin/"protocolcity"
  end

  # Best-effort stop of suite/engines so brew upgrade does not leave
  # an orphan process serving a deleted Cellar path (blank 404 on all routes).
  def post_install
    system bin/"blueprint", "stop", "--quiet"
  rescue
    nil
  end

  test do
    assert_match "setup", shell_output("#{bin}/blueprint setup --help")
    assert_match "service", shell_output("#{bin}/blueprint service --help")
    refute_predicate bin/"protocolcity", :exist?
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      BluePrint suite is installed (ProtocolCity kit).

      Next — create or adopt a workspace:

        blueprint setup
        # setup offers: keep running after you close the terminal? (macOS)

      Serve (engines start by default when a root is set):

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
