# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
# Digests from PyPI (0.1.4 suite — worklane store-slug aliases post tp-207;
# engines 0.1.2 unchanged).
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
  url "https://files.pythonhosted.org/packages/6e/5e/7ee7343bb7a9165a903cdf17f99fe29a593fa9ac6fcf16069aec3fb54377/protocolcity-0.1.4.tar.gz"
  sha256 "222d6d9749a82b2e0527f5b3cf0dfdfc58c3f265b1347fb8a201678bcc24900d"
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
