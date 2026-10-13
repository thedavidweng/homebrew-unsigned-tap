cask "cockatrice" do
  on_monterey :or_older do
    version "2.9.0,2023-09-14,Rings.of.the.Wild"
    sha256 "4524c5b95928e88073d1f8be46d881288d6d0bf07d8e65185fbebc0491f29e08"

    url "https://github.com/Cockatrice/Cockatrice/releases/download/#{version.csv.second}-Release-#{version.csv.first}/Cockatrice-#{version.csv.third}-#{version.csv.first}-macOS-11_Big_Sur.dmg"

    livecheck do
      skip "Legacy version"
    end

    caveats do
      requires_rosetta
    end
  end
  on_monterey :or_older do
    # Renamed for consistency with the current release.
    app "cockatrice.app", target: "Cockatrice.app"
  end
  on_ventura :or_newer do
    on_arm do
      on_ventura do
        version "3.1.1,2026-10-10,Reality-Check,3.1.1"
        sha256 "4ff6498a42ea4b9bd37e7ab36f5d07076e3fa322ae9c3b1e44448789b52f82d5"

        url "https://github.com/Cockatrice/Cockatrice/releases/download/#{version.csv.second}-Release-#{version.csv.first}/Cockatrice-#{version.csv.third}-#{version.csv.fourth}-macOS13_Intel.dmg"

        caveats do
          requires_rosetta
        end
      end
      on_sonoma do
        version "3.1.1,2026-10-10,Reality-Check,3.1.1"
        sha256 "4f48059bc823542c4282d6397ac4cec6ec9b1f3dc68615d36f5ded05771a5cec"

        url "https://github.com/Cockatrice/Cockatrice/releases/download/#{version.csv.second}-Release-#{version.csv.first}/Cockatrice-#{version.csv.third}-#{version.csv.fourth}-macOS14.dmg"
      end
      on_sequoia :or_newer do
        version "3.1.1,2026-10-10,Reality-Check,3.1.1"
        sha256 "b7460d315d28c533670db41341b367c3900b33368d80ff1cc887d308c37076f7"

        url "https://github.com/Cockatrice/Cockatrice/releases/download/#{version.csv.second}-Release-#{version.csv.first}/Cockatrice-#{version.csv.third}-#{version.csv.fourth}-macOS15.dmg"
      end
    end
    on_intel do
      version "3.1.1,2026-10-10,Reality-Check,3.1.1"
      sha256 "4ff6498a42ea4b9bd37e7ab36f5d07076e3fa322ae9c3b1e44448789b52f82d5"

      url "https://github.com/Cockatrice/Cockatrice/releases/download/#{version.csv.second}-Release-#{version.csv.first}/Cockatrice-#{version.csv.third}-#{version.csv.fourth}-macOS13_Intel.dmg"
    end

    livecheck do
      url :url
      regex(%r{/(\d+(?:-\d+)+)-Release-([^/]+)/Cockatrice-(.+?)-(\d+(?:\.\d+)+(?:-beta)?)-macOS[.\w]*\.dmg$}i)
      strategy :github_latest do |json, regex|
        json["assets"]&.map do |asset|
          match = asset["browser_download_url"]&.match(regex)
          next if match.blank?

          "#{match[2]},#{match[1]},#{match[3]},#{match[4]}"
        end
      end
    end
  end
  on_ventura :or_newer do
    on_arm do
      on_ventura do
        depends_on macos: :ventura
      end
      on_sonoma do
        depends_on macos: :sonoma
      end
      on_sequoia :or_newer do
        depends_on macos: :sequoia
      end
    end
    on_intel do
      depends_on macos: :ventura
    end
  end
  on_ventura :or_newer do
    app "Cockatrice.app"
  end

  name "Cockatrice"
  desc "Virtual tabletop for multiplayer card games"
  homepage "https://cockatrice.github.io/"

  depends_on :macos

  app "oracle.app"
  app "servatrice.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Cockatrice.app"],
        must_succeed: false
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/oracle.app"],
        must_succeed: false
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/servatrice.app"],
        must_succeed: false
  end

  uninstall quit: [
    "com.cockatrice.cockatrice",
    "com.cockatrice.oracle",
    "com.cockatrice.servatrice",
  ]

  zap trash: [
    "~/Library/Application Support/Cockatrice",
    "~/Library/Preferences/com.cockatrice.Cockatrice.plist",
    "~/Library/Preferences/com.cockatrice.oracle.plist",
    "~/Library/Preferences/de.cockatrice.Cockatrice.plist",
    "~/Library/Saved Application State/com.cockatrice.cockatrice.savedState",
    "~/Library/Saved Application State/com.cockatrice.oracle.savedState",
  ]
end
