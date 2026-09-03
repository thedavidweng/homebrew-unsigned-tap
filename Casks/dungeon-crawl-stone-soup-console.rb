cask "dungeon-crawl-stone-soup-console" do
  version "0.34.1"
  sha256 "c8e5c06bad71c45b6c453cc1cc554d733acc73450219732944213d64af138b17"

  url "https://github.com/crawl/crawl/releases/download/#{version}/dcss-#{version}-macos-console-universal.zip"
  name "Dungeon Crawl Stone Soup"
  desc "Game of dungeon exploration, combat and magic"
  homepage "https://crawl.develz.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Dungeon Crawl Stone Soup - Console.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/Dungeon Crawl Stone Soup"
end
