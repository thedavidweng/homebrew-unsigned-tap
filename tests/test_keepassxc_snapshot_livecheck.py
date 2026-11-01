import json
import subprocess
import unittest
from pathlib import Path


class KeePassXCSnapshotLivecheckTests(unittest.TestCase):
    def livecheck(self, root, build_page):
        script = '''
          require "json"
          require "cask/cask_loader"
          require "livecheck/strategy"
          input = JSON.parse($stdin.read)
          Homebrew::Livecheck::Strategy.define_singleton_method(:page_content) do |url|
            raise "unexpected URL: #{url}" unless url == input.fetch("url")
            { content: input.fetch("build_page") }
          end
          cask = Cask::CaskLoader::FromContentLoader.new(File.read(ARGV.fetch(0))).load(config: nil)
          puts JSON.generate(cask.livecheck.strategy_block.call(input.fetch("root"), cask.livecheck.regex))
        '''
        path = Path(__file__).resolve().parents[1] / "Casks/keepassxc@snapshot.rb"
        data = {"root": root, "build_page": build_page,
                "url": "https://snapshot.keepassxc.org/build-1000/"}
        result = subprocess.check_output(["brew", "ruby", "-e", script, str(path)],
                                         input=json.dumps(data), text=True)
        return json.loads(result)

    def test_selects_newest_numeric_build_and_macos_version(self):
        root = '<a href="build-999/">old</a><a href="build-1000/">new</a>'
        page = '<a href="KeePassXC-3.0.1-snapshot.dmg">download</a>'
        self.assertEqual(self.livecheck(root, page), "3.0.1,1000")

    def test_ignores_checksum_when_macos_download_is_missing(self):
        root = '<a href="build-1000/">new</a>'
        page = '<a href="KeePassXC-3.0.1-snapshot.dmg.DIGEST">checksum</a>'
        self.assertIsNone(self.livecheck(root, page))
