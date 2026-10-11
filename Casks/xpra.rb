cask "xpra" do
  arch arm: "arm64", intel: "x86_64"

  sha256 arm:   "b7ea123c84d5348812262c7898e73a50831751fc63b6b3b4e72b97833135e65e",
         intel: "b7093666863a366391e699bede3a24d1e0280f31039d89779955c0277072fdd3"

  on_arm do
    version "6.5.4,0"
  end
  on_intel do
    version "6.5.4,0"
  end

  url "https://xpra.org/dists/MacOS/#{arch}/Xpra-#{arch}-#{version.csv.first}-r#{version.csv.second}.dmg"
  name "Xpra"
  desc "Screen and application forwarding system"
  homepage "https://github.com/Xpra-org/xpra/"

  livecheck do
    url "https://xpra.org/dists/MacOS/#{arch}/"
    regex(/href=.*?Xpra-#{arch}[._-]v?(\d+(?:\.\d+)+)(?:[._-]r(\d+))?\.dmg/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        match[1] ? "#{match[0]},#{match[1]}" : match[0]
      end
    end
  end

  depends_on macos: :monterey

  app "Xpra.app"
  binary "#{appdir}/Xpra.app/Contents/MacOS/Xpra", target: "xpra"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Xpra.app"],
        must_succeed: false
  end

  zap delete: "/Library/Application Support/Xpra",
      trash:  [
        "~/Library/Application Support/Xpra",
        "~/Library/Saved Application State/org.xpra.xpra.savedState",
      ]
end
