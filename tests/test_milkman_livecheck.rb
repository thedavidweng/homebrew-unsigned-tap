# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
require "cask/cask_loader"

# Verify that livecheck only selects installable stable releases.
class MilkmanLivecheckTest < Minitest::Test
  def test_only_published_releases_with_macos_package_are_selected
    path = File.expand_path("../Casks/milkman.rb", __dir__)
    cask = Cask::CaskLoader::FromContentLoader.new(File.read(path)).load(config: nil)
    asset = { "name" => "milkman-dist-appbundle-macos64-bin.tgz" }
    releases = [
      { "tag_name" => "5.12.0", "assets" => [asset] },
      { "tag_name" => "5.13.0", "assets" => [] },
      { "tag_name" => "5.14.0", "assets" => [asset], "prerelease" => true },
      { "tag_name" => "5.15.0", "assets" => [asset], "draft" => true },
      { "tag_name" => "nightly", "assets" => [asset] },
      { "tag_name" => "5.16.0", "assets" => [asset] },
    ]

    assert_equal ["5.12.0", "5.16.0"], cask.livecheck.strategy_block.call(releases, cask.livecheck.regex)
  end
end
