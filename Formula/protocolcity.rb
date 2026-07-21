# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Digests filled after PyPI upload of protocolcity 0.1.6 (public README face).
# Engines: protocolcity-worklane 0.1.3 + protocolcity-workforce 0.1.2.
#
# pc-312: 0.1.4 used virtualenv_install_with_resources with only the two
# engine sdists vendored — pip resource installs run --no-deps, so fastapi/
# uvicorn never landed and WorkLane died at import (hidden by DEVNULL, fixed
# suite-side in 0.1.5). Engines now install via pip inside the formula venv:
# transitive deps resolve normally and binary wheels avoid Rust/C builds
# (pydantic-core, watchfiles, uvloop) on user machines.
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
  url "https://files.pythonhosted.org/packages/80/78/0cc728b4b924313da58c443b6a67cffe95e00160c8c19705ce603f0b8e15/protocolcity-0.1.6.tar.gz"
  sha256 "be6c6fd3b2d4d8c7ba818fcdefa0bf5c8988540db7ea893fa8952a2aaa8f9a94"
  license "Apache-2.0"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath
    # Engines pinned; deps resolved by pip (see header comment).
    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.3",
           "protocolcity-workforce==0.1.2"
  end

  test do
    assert_match "protocolcity", shell_output("#{bin}/protocolcity --help")
    # End-to-end engine import: worklane.server pulls task_server, which reads
    # surface assets at import (the 0.1.2 packaging bug) and needs fastapi/
    # uvicorn (the 0.1.4 formula bug). Catches both classes before shipping.
    system libexec/"bin/python", "-c", "import worklane.server, workforce"
  end
end
