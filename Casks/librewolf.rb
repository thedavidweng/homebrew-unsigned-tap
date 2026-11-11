cask "librewolf" do
  arch arm: "arm64", intel: "x86_64"

  version "160.0,1"
  sha256 arm:   "416a2fa78e4b67e97a48751aaf783f1fe5711d9495a52a3b1f245b89adc1c638",
         intel: "83306a47a223a41d4bf1f251ffbecc41e7999f519df70e1a22051fd4008ae0dd"

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
