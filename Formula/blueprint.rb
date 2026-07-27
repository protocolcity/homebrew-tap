# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Taught formula name: blueprint (product face = BluePrint suite).
# Twin of Formula/protocolcity.rb (compat) — same bottle, same binaries.
# PyPI distro name remains protocolcity until protocolcity-blueprint dual-publish.
# Engines: protocolcity-worklane 0.1.4 + protocolcity-workforce 0.1.4.
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
  url "https://files.pythonhosted.org/packages/b8/42/3aca7406f89ae057f841bc38387845db7dc1aa1b91efc60e16658f8ff0a4/protocolcity-0.1.19.tar.gz"
  sha256 "3a91658c2a7cc3a2a94f1c654e1d379aada9ce616e79baaf68caa68e54dcb4a9"
  license "Apache-2.0"

  depends_on "python@3.11"
  # Twin of protocolcity formula — install only one.
  conflicts_with "protocolcity",
                 because: "both install the BluePrint suite (same blueprint/protocolcity binaries)"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.4",
           "protocolcity-workforce==0.1.4"
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
