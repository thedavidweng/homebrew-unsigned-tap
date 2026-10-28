cask "fly" do
  arch arm: "arm64", intel: "amd64"

  version "8.3.2"
  sha256 arm:   "049a4b71e2a51c12e842c6e8a2ed14ddc2c010b39b4129e7ccd6bb0974916647",
         intel: "8b335ea48a68219a386639e66284e1565b20e20fc81e51bac0f831081dc886a5"

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
