# typed: false
# frozen_string_literal: true

# Formula for protocolcity/homebrew-tap.
#
# Sole formula: blueprint (product face = BluePrint suite).
#
# PyPI protocolcity-blueprint 0.1.50 sdist (pc-1468 / BluePrint #145).
# This revision (pc-1565 / homebrew-tap#19) only fixes post_install --root
# discovery + honest caveats. No PyPI cut. No BluePrint suite rewrite.
#
# Pins:
#   - suite / Cellar face: 0.1.50
#   - tip SoT: BluePrint archive @ 7e9574445f98ba4027b0089027010d4c6b0240c7
#   - engines: protocolcity-worklane==0.1.9 + protocolcity-workforce==0.1.9
#
# post_install: discover workspace --root from LaunchAgent / service.json
#   and run `blueprint upgrade --root <that-root> --quiet`. If no root:
#   skip mutate steps and warn (do not call upgrade without --root).
# Caveats: :8801 suite Map HARD HOLD. Honest about skip vs discovered root.
#
# Install:
#   brew install protocolcity/tap/blueprint
#   blueprint setup
#   blueprint serve --root <your-workspace>    # :8801
#
# Remove:
#   blueprint uninstall --app

class Blueprint < Formula
  include Language::Python::Virtualenv

  desc "BluePrint suite — setup a workspace, serve Map · Desk · Agents"
  homepage "https://github.com/protocolcity/BluePrint"
  # Formula SoT = cut tip archive for PyPI 0.1.50 (BluePrint #145 / cut tip).
  url "https://github.com/protocolcity/BluePrint/archive/7e9574445f98ba4027b0089027010d4c6b0240c7.tar.gz"
  sha256 "df6d79b88d8d6567186e6081511ade01780609d81b2df771ad18480e9eebc9a6"
  version "0.1.50"
  # post_install --root discovery (pc-1565 / homebrew-tap#19). Same 0.1.50 pin.
  revision 1
  license "Apache-2.0"

  depends_on "python@3.11"

  # PyPI suite pin 0.1.50 — sdist from cut receipt / PyPI JSON.
  resource "suite" do
    url "https://files.pythonhosted.org/packages/source/p/protocolcity-blueprint/protocolcity_blueprint-0.1.50.tar.gz"
    sha256 "c0e4eb04d490ea9422e5a843a53fdddfe9919d2be28fdf7bd1c37269d9199d16"
  end

  # Login agents that may still record --root / --binder (0.1.47 suite on
  # :8801, 0.1.50 overview, leftover three-lane map). Suite first = HARD HOLD.
  AGENT_LABELS = %w[
    com.protocolcity.suite
    com.protocolcity.blueprint-overview
    com.protocolcity.blueprint-map
  ].freeze

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Suite CLI + surfaces from the PyPI 0.1.50 pin (same cut as tip SoT).
    venv.pip_install_and_link resource("suite")

    system libexec/"bin/python", "-m", "pip", "install",
           "protocolcity-worklane==0.1.9",
           "protocolcity-workforce==0.1.9"
    system libexec/"bin/python", "-m", "pip", "uninstall", "-y", "watchfiles"
    # Drop legacy console-script name if an older wheel still shipped it.
    rm_f bin/"protocolcity"
  end

  # Discover the registered workspace, then mutate. Never call
  # `blueprint upgrade` without --root (0.1.50 CLI requires it; a swallowed
  # failure left the suite down — homebrew-tap#19).
  def post_install
    root = discover_workspace_root
    if root.nil?
      opoo <<~EOS
        post_install skipped `blueprint upgrade` — no workspace --root in a
        login LaunchAgent (#{AGENT_LABELS.join(" / ")}) or
        ~/.protocolcity/service.json. The suite was not migrated automatically.
        Restore it yourself (do not omit --root):

          blueprint upgrade --root <your-workspace>
      EOS
      return
    end

    ohai "blueprint upgrade --root #{root} --quiet"
    begin
      system bin/"blueprint", "upgrade", "--root", root, "--quiet"
    rescue ErrorDuringExecution
      opoo <<~EOS
        `blueprint upgrade --root #{root}` did not succeed. The Cellar install
        finished, but the suite may still be down. Restore:

          blueprint upgrade --root #{root}
      EOS
    end
  end

  def discover_workspace_root(home: Dir.home, env: ENV)
    self.class.discover_workspace_root(home: home, env: env)
  end

  def self.discover_workspace_root(home: Dir.home, env: ENV)
    home = Pathname.new(home)

    env_root = env["SUITE_CITY_ROOT"].to_s.strip
    return File.expand_path(env_root) if !env_root.empty? && File.directory?(File.expand_path(env_root))

    state = home/".protocolcity"/"service.json"
    if state.exist?
      begin
        raw = JSON.parse(state.read)["root"].to_s.strip
        expanded = File.expand_path(raw) unless raw.empty?
        return expanded if expanded && File.directory?(expanded)
      rescue JSON::ParserError, Errno::ENOENT
        nil
      end
    end

    agents = home/"Library"/"LaunchAgents"
    AGENT_LABELS.each do |label|
      plist = agents/"#{label}.plist"
      next unless plist.exist?

      root = extract_root_from_plist_xml(read_plist_xml(plist))
      next if root.nil?

      expanded = File.expand_path(root)
      return expanded if File.directory?(expanded)
    end
    nil
  end

  def self.read_plist_xml(path)
    raw = File.binread(path)
    stripped = raw.lstrip
    return raw if stripped.start_with?("<?xml", "<plist")

    require "open3"
    out, status = Open3.capture2("plutil", "-convert", "xml1", "-o", "-", path.to_s)
    return out if status.success? && out.include?("<plist")

    raw
  rescue Errno::ENOENT
    raw
  end

  # Prefer ProgramArguments --root, then --binder (overview / map LaunchAgent),
  # then SUITE_CITY_ROOT, then WorkingDirectory.
  def self.extract_root_from_plist_xml(xml)
    return if xml.nil? || xml.empty?

    %w[--root --binder].each do |flag|
      match = xml.match(%r{<string>#{Regexp.escape(flag)}</string>\s*<string>([^<]+)</string>})
      val = match && match[1].to_s.strip
      return val unless val.nil? || val.empty?
    end
    match = xml.match(%r{<key>SUITE_CITY_ROOT</key>\s*<string>([^<]+)</string>})
    val = match && match[1].to_s.strip
    return val unless val.nil? || val.empty?

    match = xml.match(%r{<key>WorkingDirectory</key>\s*<string>([^<]+)</string>})
    val = match && match[1].to_s.strip
    return val unless val.nil? || val.empty?

    nil
  end

  test do
    assert_match "setup", shell_output("#{bin}/blueprint setup --help")
    upgrade_help = `#{bin}/blueprint upgrade --help 2>&1`
    assert_match(/upgrade/i, upgrade_help)
    assert_match(/--root/i, upgrade_help)
    refute_predicate bin/"protocolcity", :exist?
    system libexec/"bin/python", "-c", "import worklane.server, workforce"

    caveats_text = caveats
    assert_match "blueprint upgrade --root", caveats_text
    assert_match ":8801", caveats_text
    refute_match(/post_install runs `blueprint upgrade --quiet`/, caveats_text)

    empty_home = Pathname.new(Dir.mktmpdir)
    assert_nil discover_workspace_root(home: empty_home, env: {})

    home = Pathname.new(Dir.mktmpdir)
    root_dir = home/"Projects"
    root_dir.mkpath
    agents = home/"Library"/"LaunchAgents"
    agents.mkpath
    (agents/"com.protocolcity.suite.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <plist version="1.0">
      <dict>
        <key>ProgramArguments</key>
        <array>
          <string>blueprint</string>
          <string>serve</string>
          <string>--root</string>
          <string>#{root_dir}</string>
        </array>
      </dict>
      </plist>
    XML
    assert_equal root_dir.to_s, discover_workspace_root(home: home, env: {})
  end

  def caveats
    <<~EOS
      BluePrint suite 0.1.50 is installed (engines 0.1.9).

        :8801  blueprint serve --root <your-workspace>    # suite Map HARD HOLD

      Next — create or adopt a workspace:

        blueprint setup
        blueprint serve --root <your-workspace>

      After brew upgrade/install, post_install runs
      `blueprint upgrade --root <workspace> --quiet` only when a login
      LaunchAgent (com.protocolcity.suite / com.protocolcity.blueprint-overview)
      or ~/.protocolcity/service.json records that workspace.

      If no root is discovered, post_install skips upgrade (does not claim it
      ran, and does not call `upgrade` without --root). Restore:

        blueprint upgrade --root <your-workspace>

      One-shot (no login agent):

        blueprint serve --root <your-workspace>

      Remove (stops suite/engines, then keep or delete workspace files):

        blueprint uninstall --app
    EOS
  end
end
