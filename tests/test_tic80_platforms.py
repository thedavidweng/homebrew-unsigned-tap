import json
import subprocess
import unittest
from pathlib import Path


class Tic80PlatformTests(unittest.TestCase):
    def test_platforms_keep_compatible_versions(self):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "simulate_system"
          source = File.read(ARGV.fetch(0))
          results = [:ventura, :sonoma, :sequoia].flat_map do |os|
            [:arm, :intel].map do |arch|
              Homebrew::SimulateSystem.with(os: os, arch: arch) do
                cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
                [os, arch, cask.version.to_s, cask.depends_on[:macos].minimum_version.to_s, cask.livecheck.skip?]
              end
            end
          end
          puts JSON.generate(results)
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/tic80.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["ventura", "arm", "1.1.2837", "11", True],
            ["ventura", "intel", "1.1.2837", "11", True],
            ["sonoma", "arm", "1.4.1", "14", False],
            ["sonoma", "intel", "1.1.2837", "11", True],
            ["sequoia", "arm", "1.4.1", "14", False],
            ["sequoia", "intel", "1.4.1", "15", False],
        ])
