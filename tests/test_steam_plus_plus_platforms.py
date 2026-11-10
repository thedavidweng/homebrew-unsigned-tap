import json
import subprocess
import unittest
from pathlib import Path


class SteamPlusPlusPlatformTests(unittest.TestCase):
    def test_platforms_keep_compatible_versions(self):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "simulate_system"
          source = File.read(ARGV.fetch(0))
          results = [:monterey, :ventura, :sonoma, :sequoia].flat_map do |os|
            [:arm, :intel].map do |arch|
              Homebrew::SimulateSystem.with(os: os, arch: arch) do
                cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
                [os, arch, cask.version.to_s, cask.depends_on[:macos].minimum_version.to_s, cask.livecheck.skip?]
              end
            end
          end
          puts JSON.generate(results)
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/steam-plus-plus.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["monterey", "arm", "3.1.0", "12", True],
            ["monterey", "intel", "3.1.0", "12", True],
            ["ventura", "arm", "3.1.0", "12", True],
            ["ventura", "intel", "3.1.0", "12", True],
            ["sonoma", "arm", "3.2.0", "14", False],
            ["sonoma", "intel", "3.2.0", "14", False],
            ["sequoia", "arm", "3.2.0", "14", False],
            ["sequoia", "intel", "3.2.0", "14", False],
        ])
