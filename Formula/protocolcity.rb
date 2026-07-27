# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Compat formula name (product face = BluePrint). Taught install:
#   brew install protocolcity/tap/blueprint
# This twin remains for existing installs and docs that still say protocolcity.
# Same bottle as Formula/blueprint.rb.
# Engines: protocolcity-worklane 0.1.5 + protocolcity-workforce 0.1.5.
#
# Install (compat):
#   brew install protocolcity/tap/protocolcity
# Taught CLI after either formula:
#   blueprint setup          # primary
#   protocolcity setup       # alias
#
# Remove:
#   blueprint uninstall --app

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/98/31/7d4ffd97d58f7558343f002de222e180cd1cf914a4de7587e0a174754845/protocolcity-0.1.22.tar.gz"
  sha256 "cda931220aa32a0d8b773c2aa48071f768a5e1caf1c011d354d974606001db3b"
  license "Apache-2.0"

  depends_on "python@3.11"
  # Twin of blueprint formula (taught name) — install only one.
  conflicts_with "blueprint",
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
