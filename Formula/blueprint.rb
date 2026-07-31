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
  url "https://files.pythonhosted.org/packages/be/af/7e477838b822ff4bb76bd8d8c09108dec128f5a22c0369a2acf27b1c86b6/protocolcity-0.1.32.tar.gz"
  sha256 "a5572b273df8789b6fe0ee868e594d432557c0c0f3d5dbf4de774ecdbea6dc5d"
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
