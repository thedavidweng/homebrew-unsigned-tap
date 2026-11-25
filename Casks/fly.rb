cask "fly" do
  arch arm: "arm64", intel: "amd64"

  version "8.3.4"
  sha256 arm:   "78665a1f6fdb87d3fc7be348b14985bc436bbcd8457be3e17b80e7ce5cd0d9a3",
         intel: "6d37739cc344d45254486b74d8a3fa9d7637070378a62845069544df2e86b899"

  url "https://github.com/concourse/concourse/releases/download/v#{version}/fly-#{version}-darwin-#{arch}.tgz"
  name "fly"
  desc "Official CLI tool for Concourse CI"
  homepage "https://github.com/concourse/concourse"

  depends_on macos: :ventura

  binary "fly"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
