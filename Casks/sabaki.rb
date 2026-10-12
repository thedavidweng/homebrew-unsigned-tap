cask "sabaki" do
  minimum_macos = :big_sur

  arch arm: "arm64", intel: "x64"

  on_big_sur do
    version "0.52.2"
    sha256 arm:   "e2cf00aa5ca0c2a675db847978466ba87ac2af9db33209ba7774be545b0f904c",
           intel: "5e1a38772cc6926b1880341df128ae2f6172b29128cbb206782c84df6d7ec743"

    url "https://github.com/SabakiHQ/Sabaki/releases/download/v#{version}/sabaki-v#{version}-mac-#{arch}.7z"

    livecheck do
      skip "Newer releases require macOS Monterey or later"
    end
  end
  on_monterey :or_newer do
    version "0.60.0"
    sha256 arm:   "b088788113a84748d75f63067efb99a98e95e0229dfb03d565295c70c524ed50",
           intel: "c44b9f253351e84d91b40cfd51257d12fc6772980791fbdf42e253f7f17ca992"

    url "https://github.com/SabakiHQ/Sabaki/releases/download/v#{version}/sabaki-v#{version}-mac-#{arch}.dmg"

    livecheck do
      url :url
      strategy :github_latest
    end
    minimum_macos = :monterey
  end

  name "Sabaki"
  desc "Go board and SGF editor"
  homepage "https://sabaki.yichuanshen.de/"

  depends_on macos: minimum_macos

  app "Sabaki.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Sabaki.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Sabaki",
    "~/Library/Preferences/de.yichuanshen.sabaki.plist",
    "~/Library/Saved Application State/de.yichuanshen.sabaki.savedState",
  ]
end
