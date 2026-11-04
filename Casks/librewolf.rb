cask "librewolf" do
  arch arm: "arm64", intel: "x86_64"

  version "159.0.1,1"
  sha256 arm:   "ed92b13a015059fda2e27e8b2c5de7d801843e5fa0d7ee92b11bd487f5c68bf4",
         intel: "af20edd7183c5e6f3344790f5d3cc7eaee2c8edbf5d6f56ceb8867deda29b1b3"

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
