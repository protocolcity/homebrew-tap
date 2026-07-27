# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# protocolcity 0.1.16 — Map sticky attention, Live/Deferred WO, route-on-create teach.
# Engines: protocolcity-worklane 0.1.4 + protocolcity-workforce 0.1.4.
#
# Install:
#   brew install protocolcity/tap/protocolcity
#   blueprint setup          # taught (BluePrint suite)
#   protocolcity setup       # same CLI (compat alias)
#
# Remove:
#   blueprint uninstall --app

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/82/48/b92e091dbdc41b9731cda16de490b8a7b26bacee492744f9ec844f96b549/protocolcity-0.1.16.tar.gz"
  sha256 "dc335dd7c183fb477431ff664ee9e7c80593a86f7d6019df6744a6d8b973b9ed"
  license "Apache-2.0"

  depends_on "python@3.11"

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
