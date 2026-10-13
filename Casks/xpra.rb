cask "xpra" do
  arch arm: "arm64", intel: "x86_64"

  on_arm do
    version "6.5.5,0"
    sha256 "b98262da8c3a74234d755123b064200f737c11c720a5d6380ab638bb1f309af0"
    livecheck do
      url "https://xpra.org/dists/MacOS/#{arch}/"
      regex(/href=.*?Xpra-#{arch}[._-]v?(\d+(?:\.\d+)+)(?:[._-]r(\d+))?\.dmg/i)
      strategy :page_match do |page, regex|
        page.scan(regex).map do |match|
          match[1] ? "#{match[0]},#{match[1]}" : match[0]
        end
      end
    end
  end
  on_intel do
    on_sonoma :or_older do
      version "6.5.3,0"
      sha256 "5bfaff0d6e7f6d107f8be676fdb5497f101446deed74d4a797db5fe8394af529"

      livecheck do
        skip "Legacy Intel release for macOS Sonoma and older"
      end
    end
    on_sequoia :or_newer do
      version "6.5.4,0"
      sha256 "b7093666863a366391e699bede3a24d1e0280f31039d89779955c0277072fdd3"
      livecheck do
        url "https://xpra.org/dists/MacOS/#{arch}/"
        regex(/href=.*?Xpra-#{arch}[._-]v?(\d+(?:\.\d+)+)(?:[._-]r(\d+))?\.dmg/i)
        strategy :page_match do |page, regex|
          page.scan(regex).map do |match|
            match[1] ? "#{match[0]},#{match[1]}" : match[0]
          end
        end
      end
    end
  end

  url "https://xpra.org/dists/MacOS/#{arch}/Xpra-#{arch}-#{version.csv.first}-r#{version.csv.second}.dmg"
  name "Xpra"
  desc "Screen and application forwarding system"
  homepage "https://github.com/Xpra-org/xpra/"

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
