# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# protocolcity 0.1.13 — Overview project names → project brief.
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
  url "https://files.pythonhosted.org/packages/f5/40/edcd1665d86df7f30f04c16e4d0a1a8b0b9fc830ce8c7d1047e2399b8796/protocolcity-0.1.13.tar.gz"
  sha256 "5c22177d86325378357f801b43278e71d15847d6e39bb41c84a302784faa3005"
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
