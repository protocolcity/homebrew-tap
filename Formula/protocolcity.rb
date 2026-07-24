# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# protocolcity 0.1.11 — serve frees ports before bind.
# Engines: protocolcity-worklane 0.1.3 + protocolcity-workforce 0.1.3.
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
  url "https://files.pythonhosted.org/packages/66/71/1f7ad06293579c2b1c7a5dc0bdbc7df35e522d5022a4e901566de056d0ed/protocolcity-0.1.11.tar.gz"
  sha256 "a2ff1f225673209e72fd45e434495d9ed93af6fa8db88e1b042574efb46c30ee"
  license "Apache-2.0"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.3",
           "protocolcity-workforce==0.1.3"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
    assert_match "setup", shell_output("#{bin}/protocolcity setup --help")
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
