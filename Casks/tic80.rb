cask "tic80" do
  # NOTE: "80" is not a version number, but an intrinsic part of the product name
  app_name = "tic80.app"
  minimum_macos = :big_sur

  on_arm do
    on_ventura :or_older do
      version "1.1.2837"
      sha256 "324e91d08fb5dcfaf2f41dc846b89465074b5db3b5aa63befc3fdb664493c1b9"

      url "https://github.com/nesbox/TIC-80/releases/download/v#{version}/tic80-v#{version.major_minor}-mac.dmg"

      livecheck do
        skip "Legacy macOS release"
      end

      caveats do
        requires_rosetta
      end
    end
    on_sonoma :or_newer do
      version "1.4.1"
      sha256 "a2b116afd56b9148fe0c2440e607a8d0583f4a85e3391888d25d1c4afc390308"

      url "https://github.com/nesbox/TIC-80/releases/download/v#{version}/tic80-v#{version.major_minor}-mac-arm64.dmg"

      livecheck do
        url :url
        strategy :github_latest
      end

      app_name = "TIC-80.app"
      minimum_macos = :sonoma
    end
  end
  on_intel do
    on_sonoma :or_older do
      version "1.1.2837"
      sha256 "324e91d08fb5dcfaf2f41dc846b89465074b5db3b5aa63befc3fdb664493c1b9"

      url "https://github.com/nesbox/TIC-80/releases/download/v#{version}/tic80-v#{version.major_minor}-mac.dmg"

      livecheck do
        skip "Legacy macOS release"
      end
    end
    on_sequoia :or_newer do
      version "1.4.1"
      sha256 "6d16bd94488a96da199d769537c7ba08a60f2b4632ab386462f6d15db110ffd2"

      url "https://github.com/nesbox/TIC-80/releases/download/v#{version}/tic80-v#{version.major_minor}-mac.dmg"

      livecheck do
        url :url
        strategy :github_latest
      end

      app_name = "TIC-80.app"
      minimum_macos = :sequoia
    end
  end

  name "TIC-80"
  desc "Fantasy computer for making, playing and sharing tiny games"
  homepage "https://tic80.com/"

  depends_on macos: minimum_macos

  app app_name, target: "tic80.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/tic80.app"],
        must_succeed: false
  end

  uninstall quit: "com.nesbox.tic"

  zap trash: [
    "~/Library/Application Support/com.nesbox.tic",
    "~/Library/Saved Application State/com.nesbox.tic.savedState",
  ]
end
