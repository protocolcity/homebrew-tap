# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Digests filled after PyPI upload of protocolcity 0.1.8 (setup/uninstall).
# Engines: protocolcity-worklane 0.1.3 + protocolcity-workforce 0.1.2.
#
# watchfiles: uvicorn[standard] pulls it for --reload only. Homebrew then
# rewrites the .so dylib ID into Cellar paths and fails (headerpad).
# Engines never use --reload in serve mode — drop watchfiles after pip.
#
# Install:
#   brew install protocolcity/tap/protocolcity
#   protocolcity setup
#
# Remove:
#   protocolcity uninstall
#   brew uninstall protocolcity/tap/protocolcity

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/f2/86/b05e2e1aed98d1ffa90dea3006d685849e89b5ccc2261f99cde84071dc25/protocolcity-0.1.8.tar.gz"
  sha256 "8984c4390c2292edf4f393ae4dd92f2ad8ab16ca2c42a08e8fc09a53fdab38d3"
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

      Remove (asks whether to keep or delete your workspace files):

        protocolcity uninstall
        brew uninstall protocolcity/tap/protocolcity
    EOS
  end
end
