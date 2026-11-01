"""Reject automated cask updates that remove declared macOS platforms."""
import json
import subprocess
import sys


def output(*args):
    return subprocess.check_output(args, text=True)


def lost_platforms(before, after):
    script = '''
require "cask/cask_loader"; require "macos_version"; require "simulate_system"; require "utils/bottles"; require "json"
lost = []
MacOSVersion::SYMBOLS.each_key do |os|
  [:arm, :intel].each do |arch|
    supported = Homebrew::SimulateSystem.with(os: os, arch: arch) do
      tag = Utils::Bottles::Tag.new(system: os, arch: arch)
      ARGV.map do |source|
        cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
        cask.platform_supported?(tag)
      end
    end
    lost << "#{os} / #{arch}" if supported == [true, false]
  end
end
puts JSON.generate(lost)
'''
    return json.loads(output("brew", "ruby", "-e", script, "--", before, after))


def main(base, head):
    paths = output("git", "diff", "--name-only", "--diff-filter=M", base, head, "--", "Casks/*.rb").splitlines()
    lost = []
    for path in paths:
        before, after = (output("git", "show", f"{ref}:{path}") for ref in (base, head))
        lost.extend(f"{path}: {platform}" for platform in lost_platforms(before, after))
    if lost:
        raise SystemExit("Cask update removes declared platform support:\n" + "\n".join(lost))
    print(f"No declared macOS platform support removed from {len(paths)} cask(s).")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: check_cask_compatibility.py BASE HEAD")
    main(*sys.argv[1:])
