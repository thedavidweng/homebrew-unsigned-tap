cask "librewolf" do
  arch arm: "arm64", intel: "x86_64"

  version "159.0,1"
  sha256 arm:   "4921976ad4cce4d2de2f9929b8f3c6ba299be10c3513d828feb026a3316a4378",
         intel: "8d9c85e3ef1fd1a4bebb3be5b8f7be531131df3958b6a73b899c7b82c0d7d3c6"

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
