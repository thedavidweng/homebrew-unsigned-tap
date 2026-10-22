cask "librewolf" do
  arch arm: "arm64", intel: "x86_64"

  version "158.0.1,2"
  sha256 arm:   "974703e22c5710529b0dc0e14259eafbb9e2d4767180353da722c2f25db0d81e",
         intel: "e4dec3240e6c43c4ad595d4ccaf1d84356303702303523f575f63fc1d1326334"

  url "https://codeberg.org/api/packages/librewolf/generic/librewolf/#{version.tr(",", "-")}/librewolf-#{version.tr(",", "-")}-macos-#{arch}-package.dmg"
  name "LibreWolf"
  desc "Web browser"
  homepage "https://librewolf.net/"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url "https://codeberg.org/api/v1/repos/librewolf/bsys6/releases/latest"
    regex(/^v?(\d+(?:[.-]\d+)+)$/i)
    strategy :json do |json, regex|
      json["tag_name"]&.[](regex, 1)&.tr("-", ",")
    end
  end

  depends_on :macos

  app "LibreWolf.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  binary "librewolf.wrapper.sh", target: "librewolf"

  preflight_steps do
    write_file "librewolf.wrapper.sh", <<~EOS
      #!/bin/sh
      exec '{{appdir}}/LibreWolf.app/Contents/MacOS/librewolf' "$@"
    EOS
  end

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/LibreWolf.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.librewolf",
    "~/Library/Application Support/LibreWolf",
    "~/Library/Caches/LibreWolf Community",
    "~/Library/Caches/LibreWolf",
    "~/Library/Preferences/io.gitlab.librewolf-community.librewolf.plist",
    "~/Library/Saved Application State/io.gitlab.librewolf-community.librewolf.savedState",
  ]
end
