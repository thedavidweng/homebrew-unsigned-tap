cask "fly" do
  arch arm: "arm64", intel: "amd64"

  version "8.3.1"
  sha256 arm:   "d0d0029531707b81c217e0492b35fa54123ad48c85448f4f0be1902ebcb9d222",
         intel: "0c8fd1fcfc443593c9262b6abd87786f97ebe8c63514831b7d37b953b29ccdd8"

  url "https://github.com/concourse/concourse/releases/download/v#{version}/fly-#{version}-darwin-#{arch}.tgz"
  name "fly"
  desc "Official CLI tool for Concourse CI"
  homepage "https://github.com/concourse/concourse"

  depends_on :macos

  binary "fly"

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
