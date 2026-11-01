import json
import subprocess
import unittest
from pathlib import Path


class BrewtargetPlatformTests(unittest.TestCase):
    def test_platforms_keep_compatible_versions(self):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "simulate_system"
          source = File.read(ARGV.fetch(0))
          results = [:sonoma, :sequoia, :tahoe].flat_map do |os|
            [:arm, :intel].map do |arch|
              Homebrew::SimulateSystem.with(os: os, arch: arch) do
                cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
                [os, arch, cask.version.to_s, cask.depends_on[:macos].minimum_version.to_s,
                 cask.depends_on[:arch], cask.livecheck.skip?]
              end
            end
          end
          Homebrew::SimulateSystem.with(os: :linux, arch: :arm) do
            cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
            results << [:linux, cask.depends_on.key?(:macos)]
          end
          puts JSON.generate(results)
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/brewtarget.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)], text=True)
        self.assertEqual(json.loads(result), [
            ["sonoma", "arm", "5.1.1", "15", [{"type": "arm", "bits": 64}], True],
            ["sonoma", "intel", "5.1.1", "15", [{"type": "arm", "bits": 64}], True],
            ["sequoia", "arm", "5.1.1", "15", [{"type": "arm", "bits": 64}], True],
            ["sequoia", "intel", "5.1.1", "15", [{"type": "arm", "bits": 64}], True],
            ["tahoe", "arm", "5.2.0", "26", [{"type": "arm", "bits": 64}], False],
            ["tahoe", "intel", "5.2.0", "26", [{"type": "arm", "bits": 64}], False],
            ["linux", True],
        ])
