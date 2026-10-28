cask "whoozle-android-file-transfer" do
  version "4.5"
  sha256 "05d55ec3015d514cbe9a673c2f6034ea376cb9ad5ab875f8fd4000335605b0b2"

  url "https://github.com/whoozle/android-file-transfer-linux/releases/download/v#{version}/AndroidFileTransferForLinux.dmg"
  name "Android File Transfer"
  desc "Android File Transfer for Linux"
  homepage "https://whoozle.github.io/android-file-transfer-linux/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"] || release["prerelease"]
        next unless release["assets"].any? { |asset| asset["name"] == "AndroidFileTransferForLinux.dmg" }

        release["tag_name"][regex, 1]
      end
    end
  end

  depends_on :macos

  app "Android File Transfer for Linux.app"
  binary "#{appdir}/Android File Transfer for Linux.app/Contents/SharedSupport/bin/aft-mtp-cli"
  binary "#{appdir}/Android File Transfer for Linux.app/Contents/SharedSupport/bin/aft-mtp-mount"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Android File Transfer for Linux.app"],
        must_succeed: false
  end

  zap :not_required

  caveats do
    requires_rosetta
  end
end
