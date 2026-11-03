cask "fly" do
  arch arm: "arm64", intel: "amd64"

  version "8.3.3"
  sha256 arm:   "184af588be75e8f3f2a8b9eeb718acc4092693ad38a42a6c4ce3565cfb1a9e77",
         intel: "b3b01e16c1d427abdcfc3900506765b2aaa58caf7888e23b9b014a001568754d"

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
