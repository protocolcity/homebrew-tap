# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap (pc-260).
# Digests from PyPI. One formula = full suite (CLI + engine resources).
#
# Install (preferred one-liner):
#   brew install protocolcity/tap/protocolcity
#   protocolcity found ~/my-city
#   protocolcity serve --with-engines
#
# Upgrade after Formula bump:
#   brew update
#   brew upgrade protocolcity/tap/protocolcity
#
# Product source repos may stay private; this Formula installs from PyPI only.

class Protocolcity < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — found a city, serve Map · Desk · Roster"
  homepage "https://pypi.org/project/protocolcity/"
  url "https://files.pythonhosted.org/packages/27/8e/11c16398f044b960ed246f29a66dad19bc01fe37cbeb23eeae58a517d1a3/protocolcity-0.1.1.tar.gz"
  sha256 "f292e093df48262bd136d738e70866ae0ab60446910a502b614070595c167f44"
  license "Apache-2.0"

  depends_on "python@3.11"

  resource "protocolcity-worklane" do
    url "https://files.pythonhosted.org/packages/6e/4b/7491ce9048a01a73da6b1d48b73e8bf710adcf7029ce828f3b0cffeddd86/protocolcity_worklane-0.1.0.tar.gz"
    sha256 "212e9b9c6855d8653dec4b1fe08ed1acf86022e6ae12a838cbcec235f44a999f"
  end

  resource "protocolcity-workforce" do
    url "https://files.pythonhosted.org/packages/f5/07/ceb6199dbc5f43eb0ccc13bd49d20b7f7a16d2f0ee5882c280d276666da5/protocolcity_workforce-0.1.0.tar.gz"
    sha256 "dfbe53ea411aff99cabe1585a35410eaffe19b3d523225a907c24664cf65b9b1"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
  end
end
