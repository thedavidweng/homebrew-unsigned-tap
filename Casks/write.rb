cask "write" do
  version "3.0.0"
  sha256 "036e75f00f47c3dc33cdddfe7b2449d5bcff696992389138467de1f9757b6c57"

  url "https://www.styluslabs.com/write/write#{version.no_dots}.dmg"
  name "Write"
  desc "Word processor for handwriting"
  homepage "https://www.styluslabs.com/"

  livecheck do
    url "https://www.styluslabs.com/download/write-dmg"
    regex(/write[._-]?v?(\d+)\.dmg/i)
    strategy :header_match do |headers, regex|
      match = headers["location"]&.match(regex)
      next if match.blank?

      match[1].include?(".") ? match[1] : match[1].sub(/(\d)(\d)(\d)/, '\1.\2.\3')
    end
  end


  depends_on :macos

  app "Write.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.config/styluslabs",
    "~/Library/Saved Application State/com.styluslabs.write3mac.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
