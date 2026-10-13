cask "qtpass" do
  on_arm do
    on_monterey :or_older do
      version "1.7.0"
      sha256 "4aa8e1ac84c8d6434fcacc68df3549a569e2b969c7b19c1f645038aefcb9c852"

      livecheck do
        skip "Pinned release for macOS Monterey"
      end
    end
    on_ventura :or_newer do
      version "1.8.3"
      sha256 "384267b8dfb20b78ec3f82ce27c4ad144c36dec00622de6de09bfe34ad32dd46"

      livecheck do
        url :url
        strategy :github_latest
      end
    end
  end
  on_intel do
    version "1.4.0"
    sha256 "cef58227b50f3eda4e4c150cb0afc7875c55c9226a91076d41e44b897629a92b"

    livecheck do
      skip "Pinned Intel release; newer macOS packages contain only ARM64 binaries"
    end
  end

  url "https://github.com/IJHack/qtpass/releases/download/v#{version}/QtPass-#{version}.dmg"
  name "QtPass"
  desc "Multi-platform GUI for pass, the standard unix password manager"
  homepage "https://qtpass.org/"

  depends_on macos: :monterey

  app "QtPass.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/QtPass.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/org.ijhack.QtPass.plist",
    "~/Library/Saved Application State/org.qtpass.savedState",
  ]
end
