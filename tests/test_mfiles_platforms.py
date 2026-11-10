import json
import subprocess
import unittest
from pathlib import Path


class MfilesPlatformTests(unittest.TestCase):
    def test_platforms_keep_compatible_versions(self):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "simulate_system"
          source = File.read(ARGV.fetch(0))
          results = [:catalina, :big_sur, :monterey, :sequoia].flat_map do |os|
            [:arm, :intel].map do |arch|
              Homebrew::SimulateSystem.with(os: os, arch: arch) do
                cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
                [os, arch, cask.version.to_s, cask.livecheck.skip?]
              end
            end
          end
          puts JSON.generate(results)
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/mfiles.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["catalina", "arm", "2.5.3,20240328", True],
            ["catalina", "intel", "2.5.3,20240328", True],
            ["big_sur", "arm", "2.5.3,20240328", True],
            ["big_sur", "intel", "2.5.3,20240328", True],
            ["monterey", "arm", "2.6.1,2026110601", False],
            ["monterey", "intel", "2.6.1,2026110601", False],
            ["sequoia", "arm", "2.6.1,2026110601", False],
            ["sequoia", "intel", "2.6.1,2026110601", False],
        ])
