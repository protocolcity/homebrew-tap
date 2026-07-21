# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Digests filled 2026-07-21 from PyPI after protocolcity 0.1.5 +
# protocolcity-worklane 0.1.3 upload (first-user install fixes).
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
  url "https://files.pythonhosted.org/packages/9e/84/c50a6e9c5de404c9e58bb4b7f5ce1692e867ccea104c5ebca58a2de9e30f/protocolcity-0.1.5.tar.gz"
  sha256 "b4f0700445e09d9ad38f8d3f59bce207bc7574163ee746c5794f89bd2e3e5d42"
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
