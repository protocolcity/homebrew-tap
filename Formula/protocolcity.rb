# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
# Digests from PyPI (0.1.3 suite re-cut — citylens /api/generation + suite kit;
# engines 0.1.2 — task_server split + hire/engine hygiene).
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
  url "https://files.pythonhosted.org/packages/ab/39/638d4729f01d6bd551c5f9e1a88a8826556c8844ffb9e83a3268faa15b53/protocolcity-0.1.3.tar.gz"
  sha256 "7cdcf4dedd3ad347c1c6bd25bc9a9bc49d2e5a3b7d0361b699ea3a76f982b172"
  license "Apache-2.0"

  depends_on "python@3.11"

  resource "protocolcity-worklane" do
    url "https://files.pythonhosted.org/packages/a7/72/3c75abf88b8e81a0bec6ca7734f35022ba8e3dc1b36f9caff9057290aebc/protocolcity_worklane-0.1.2.tar.gz"
    sha256 "4f25e8e445aa148d40dd8c9fa13a0917d0e1a8c7519064092d01f1d14050c42c"
  end

  resource "protocolcity-workforce" do
    url "https://files.pythonhosted.org/packages/bb/40/0cba77a3f963d9ec67d51b2680ee84b02ff3d14f42fbbc5d7dee4d2a2e09/protocolcity_workforce-0.1.2.tar.gz"
    sha256 "c25a6e602153414ecf99edfac06f3f2e2c60fc66443dd9fd7b1dd22ee5a11580"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
  end
end
