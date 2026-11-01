import json
import subprocess
import unittest
from pathlib import Path


class QtPassPlatformTests(unittest.TestCase):
    def test_platforms_keep_compatible_versions(self):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "simulate_system"
          source = File.read(ARGV.fetch(0))
          results = [:monterey, :ventura, :sequoia].flat_map do |os|
            [:arm, :intel].map do |arch|
              Homebrew::SimulateSystem.with(os: os, arch: arch) do
                cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
                [os, arch, cask.version.to_s, cask.depends_on[:macos].minimum_version.to_s, cask.livecheck.skip?]
              end
            end
          end
          [:arm, :intel].each do |arch|
            Homebrew::SimulateSystem.with(os: :linux, arch: arch) do
              cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
              results << [:linux, arch, cask.depends_on.key?(:macos)]
            end
          end
          puts JSON.generate(results)
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/qtpass.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["monterey", "arm", "1.7.0", "12", True],
            ["monterey", "intel", "1.4.0", "12", True],
            ["ventura", "arm", "1.8.4", "13", False],
            ["ventura", "intel", "1.4.0", "12", True],
            ["sequoia", "arm", "1.8.4", "13", False],
            ["sequoia", "intel", "1.4.0", "12", True],
            ["linux", "arm", True],
            ["linux", "intel", True],
        ])
