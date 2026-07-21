# protocolcity/homebrew-tap

Homebrew tap for the **ProtocolCity** suite — **one formula, full suite**.

```bash
brew install protocolcity/tap/protocolcity
protocolcity found ~/my-city
protocolcity serve --with-engines
# → http://127.0.0.1:8801/
```

That installs the BluePrint CLI and pulls WorkLane + WorkForce engines from
[PyPI](https://pypi.org/project/protocolcity/). You do **not** need three
`brew install` commands, and you do **not** need the product GitHub repos
to be public (install is PyPI + this tap only).

Packages: `protocolcity` · `protocolcity-worklane` · `protocolcity-workforce`.

Later (optional): a `homebrew-core` PR would enable bare `brew install protocolcity`.
