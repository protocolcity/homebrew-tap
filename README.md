# protocolcity/homebrew-tap

Homebrew tap for the **BluePrint** suite — **one install, full suite**.

```bash
brew tap protocolcity/tap
brew trust protocolcity/tap   # once — third-party tap (both formula twins)
brew install protocolcity/tap/blueprint
blueprint setup               # menu: opt 2 asks for the full path to your folder
# or: blueprint setup --adopt-workspace ~/path/to/existing
blueprint serve --root ~/my-workspace --with-engines
# → http://127.0.0.1:8801/
```

That installs the **BluePrint** CLI and pulls WorkLane + WorkForce engines from
[PyPI](https://pypi.org/project/protocolcity/). You do **not** need three
`brew install` commands, and you do **not** need the product GitHub repos
to be public (install is PyPI + this tap only).

| Formula | Role |
|---|---|
| **`blueprint`** | **Taught** — product face |
| **`protocolcity`** | Compat twin (same bottle; conflicts if both installed) |

After install, both commands work: **`blueprint`** (primary) · **`protocolcity`** (alias).

Packages on PyPI: `protocolcity` · `protocolcity-worklane` · `protocolcity-workforce`
(preferred future kit name: `protocolcity-blueprint`).

### What is a tap?

Homebrew’s default catalog is **homebrew-core**. A **tap** is an extra formula
repo we control. This repo is that catalog entry — not the app itself. The
formula downloads the sdist from PyPI and installs engines into the same venv.

### Product goal

| Today | Goal |
|---|---|
| `brew install protocolcity/tap/blueprint` | Shorter core install when accepted |
| Custom tap (this repo) | Formula accepted into **homebrew-core** (name TBD with core policy) |

One formula already = full suite. Core acceptance is the remaining discovery
step for a shorter worldwide command.

Remove:

```bash
brew uninstall protocolcity/tap/blueprint
# if you installed the compat name:
# brew uninstall protocolcity/tap/protocolcity
# optional: brew untap protocolcity/tap
```
