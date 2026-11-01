import json
import subprocess
import unittest
from pathlib import Path


class UeliPlatformTests(unittest.TestCase):
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
        path = Path(__file__).resolve().parents[1] / "Casks/ueli.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["monterey", "arm", "9.29.0", "12", True],
            ["monterey", "intel", "9.29.0", "12", True],
            ["ventura", "arm", "9.29.1", "13", False],
            ["ventura", "intel", "9.29.1", "13", False],
            ["sequoia", "arm", "9.29.1", "13", False],
            ["sequoia", "intel", "9.29.1", "13", False],
            ["linux", "arm", True],
            ["linux", "intel", True],
        ])
