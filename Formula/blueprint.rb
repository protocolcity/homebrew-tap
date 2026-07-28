# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Taught formula name: blueprint (product face = BluePrint suite).
# Twin of Formula/protocolcity.rb (compat) — same bottle, same binaries.
# PyPI distro name remains protocolcity until protocolcity-blueprint dual-publish.
# Engines: protocolcity-worklane 0.1.5 + protocolcity-workforce 0.1.5.
#
# Install (taught):
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#
# Compat:
#   brew install protocolcity/tap/protocolcity
#   protocolcity setup   # same CLI
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/ba/40/e3a8fdd2464a91909704e34890ee1b89546564c8df5a43265dc81110560a/protocolcity-0.1.23.tar.gz"
  sha256 "2ee0db1de295ed155e211759f852c8f6be6c6f6a73f206877a3a5652427e9907"
  license "Apache-2.0"

  depends_on "python@3.11"
  # Twin of protocolcity formula — install only one.
  conflicts_with "protocolcity",
                 because: "both install the BluePrint suite (same blueprint/protocolcity binaries)"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.5",
           "protocolcity-workforce==0.1.5"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
  end

  # Best-effort stop of suite/engines so brew upgrade does not leave
  # an orphan process serving a deleted Cellar path (blank 404 on all routes).
  def post_install
    system bin/"protocolcity", "stop", "--quiet"
  rescue
    nil
  end

  test do
    assert_match "setup", shell_output("#{bin}/protocolcity setup --help")
    assert_match "service", shell_output("#{bin}/protocolcity service --help")
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      BluePrint suite is installed (ProtocolCity kit).

      Next — create or adopt a workspace:

        blueprint setup
        # or: protocolcity setup

      Serve (engines start by default when a root is set):

        blueprint serve --root <your-workspace>

      Keep running after you close the terminal (macOS):

        blueprint service install --root <your-workspace>

      If BluePrint was running during upgrade, restart once:

        blueprint stop
        blueprint serve --root <your-workspace>
        # or: blueprint service install --root <your-workspace>

      Remove (stops suite/engines, then keep or delete workspace files):

        blueprint uninstall --app
    EOS
  end
end
