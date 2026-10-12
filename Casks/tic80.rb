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
      version "1.3.1"
      sha256 "b01cfae15c4c7884d2a0fb22e3b459a4d326da5e252ad5f5e85cd0ab3dc7bf75"

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
      version "1.3.1"
      sha256 "58902d9b51eb068081a5e0bbf45d49e1c8de0263135b5cba96fbc3e1039c55e2"

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
