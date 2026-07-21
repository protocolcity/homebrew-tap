# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
# Digests from PyPI (0.1.2 suite re-cut — live shell pulse + selective SSE).
#
# Install (preferred one-liner):
#   brew install protocolcity/tap/protocolcity
#   protocolcity found ~/my-city
#   protocolcity serve --with-engines
#
# Upgrade after Formula bump:
#   brew update
#   brew upgrade protocolcity/tap/protocolcity

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — found a city, serve Map · Desk · Roster (live pulse)"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/f9/82/d5bdf1dbf4484480ee2ac5277d8d8dbdbf7cd68b13912ff60145c63ba647/protocolcity-0.1.2.tar.gz"
  sha256 "100ed70edd064aa5e8683d3e593d6a7d4f2401fdce098f82828730c3b8b8ee28"
  license "Apache-2.0"

  depends_on "python@3.11"

  resource "protocolcity-worklane" do
    url "https://files.pythonhosted.org/packages/f5/6a/0243597abf9fdd98e503515edff2e6e42024d430c4af9b8474460195e878/protocolcity_worklane-0.1.1.tar.gz"
    sha256 "4edb2aed6eda39990b0ff9e966450ad465f4ac12b3b4bdf44ca253a7abcf657d"
  end

  resource "protocolcity-workforce" do
    url "https://files.pythonhosted.org/packages/ec/96/73df3e54d3fecaca219550969117f0cecac9812293f532d07903cfba56e0/protocolcity_workforce-0.1.1.tar.gz"
    sha256 "2ff014f3c89e766edd49f5fc2c200ebed4056ea0d661ab11cc1daa46f05f097b"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
  end
end
