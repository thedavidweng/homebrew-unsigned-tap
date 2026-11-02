import json
import subprocess
import unittest
from pathlib import Path


class MilkmanLivecheckTests(unittest.TestCase):
    def test_only_published_releases_with_macos_package_are_selected(self):
        asset = {"name": "milkman-dist-appbundle-macos64-bin.tgz"}
        releases = [
            {"tag_name": "5.12.0", "assets": [asset]},
            {"tag_name": "5.13.0", "assets": []},
            {"tag_name": "5.14.0", "assets": [asset], "prerelease": True},
            {"tag_name": "5.15.0", "assets": [asset], "draft": True},
            {"tag_name": "nightly", "assets": [asset]},
            {"tag_name": "5.16.0", "assets": [asset]},
        ]
        script = '''
          require "json"
          require "cask/cask_loader"
          cask = Cask::CaskLoader::FromContentLoader.new(File.read(ARGV.fetch(0))).load(config: nil)
          puts JSON.generate(cask.livecheck.strategy_block.call(JSON.parse($stdin.read), cask.livecheck.regex))
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/milkman.rb"
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)],
                                         input=json.dumps(releases), text=True)
        self.assertEqual(json.loads(result), ["5.12.0", "5.16.0"])
