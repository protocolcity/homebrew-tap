# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# protocolcity 0.1.9 — uninstall stops suite/engines (DMG-like).
# Engines: protocolcity-worklane 0.1.3 + protocolcity-workforce 0.1.2.
#
# watchfiles: dropped after pip (headerpad / dylib ID noise on brew relocate).
#
# Install:
#   brew install protocolcity/tap/protocolcity
#   protocolcity setup
#
# Remove:
#   protocolcity uninstall --app

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/c5/40/5af382c89e80dccb95bc05377f3e274a157f53de44a1b9eea3fce476950e/protocolcity-0.1.9.tar.gz"
  sha256 "e959fca524e75636217ce3f1ce8df3584b6fee88a5f7e1a6841427421c9a36fe"
  license "Apache-2.0"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.3",
           "protocolcity-workforce==0.1.2"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
    assert_match "setup", shell_output("#{bin}/protocolcity setup --help")
    assert_match "uninstall", shell_output("#{bin}/protocolcity uninstall --help")
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end

  def caveats
    <<~EOS
      ProtocolCity is installed. Next — create or adopt a workspace:

        protocolcity setup

      Remove (stops suite/engines, then keep or delete workspace files):

        protocolcity uninstall --app
    EOS
  end
end
