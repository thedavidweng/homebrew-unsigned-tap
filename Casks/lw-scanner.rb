cask "lw-scanner" do
  arch arm: "arm64", intel: "amd64"

  version "0.29.0"
  sha256 arm:   "ce97eb484b43e98a1264afd07681304dfc1c7dd49df2872d9fb5506d6a552d08",
         intel: "a2cc6deb3ace66e3ccbc643544ca4598934dcca85bf69d9af9a875353e358328"

  url "https://github.com/lacework/lacework-vulnerability-scanner/releases/download/v#{version}/lw-scanner-darwin-#{arch}.zip"
  name "Lacework vulnerability scanner"
  desc "Lacework inline scanner"
  homepage "https://docs.lacework.net/console/local-scanning-quickstart"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos

  binary "bin/lw-scanner"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.config/lw-scanner"
end
