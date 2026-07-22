# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# protocolcity 0.1.10 — serve frees ports before bind.
# Engines: protocolcity-worklane 0.1.3 + protocolcity-workforce 0.1.2.
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
  url "https://files.pythonhosted.org/packages/84/33/d9632a07aa871e053d1bb49ce738458cafc2b8e02e2b7750baaee32c88f1/protocolcity-0.1.10.tar.gz"
  sha256 "210b4ec00a7081d7337c188665faff75d1b106ca33de795386ba34f6c79133f3"
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
