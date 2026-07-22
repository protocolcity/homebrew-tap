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

### What is a tap?

Homebrew’s default catalog is **homebrew-core**. A **tap** is an extra formula
repo we control. This repo is that catalog entry — not the app itself. The
formula downloads the sdist from PyPI and installs engines into the same venv.

### Product goal

| Today | Goal |
|---|---|
| `brew install protocolcity/tap/protocolcity` | `brew install protocolcity` |
| Custom tap (this repo) | Formula accepted into **homebrew-core** |

One formula already = full suite. Core acceptance is the remaining discovery
step for a shorter worldwide command.

Remove:

```bash
brew uninstall protocolcity/tap/protocolcity
# optional: brew untap protocolcity/tap
```
