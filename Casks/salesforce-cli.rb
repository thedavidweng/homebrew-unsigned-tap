cask "salesforce-cli" do
  arch arm: "arm64", intel: "x64"

  version "2.159.7,bd525eb"
  sha256 arm:   "7c26d1a67c0bc3bf8869df1e86a1bf2f98b3933745b2265e4a7d8f3a0cf46fd1",
         intel: "cf8e5daf88c512c02630a0ee3f89f874c230a2e54cc5442aa35fcf2b6c8a9b15"

  url "https://github.com/salesforcecli/cli/releases/download/#{version.csv.first}/sf-v#{version.csv.first}-#{version.csv.second}-#{arch}.pkg"
  name "Salesforce CLI"
  desc "CLI tools for Salesforce"
  homepage "https://github.com/salesforcecli/cli"

  livecheck do
    url "https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-darwin-#{arch}-buildmanifest", user_agent: :browser
    strategy :json do |json|
      next if json["version"].blank? || json["sha"].blank?

      "#{json["version"]},#{json["sha"]}"
    end
  end

  depends_on macos: :ventura

  pkg "sf-v#{version.csv.first}-#{version.csv.second}-#{arch}.pkg"

  uninstall pkgutil: "com.salesforce.cli",
            delete:  [
              "/usr/local/bin/sf",
              "/usr/local/bin/sfdx",
            ]

  zap trash: [
    "~/.cache/sf",
    "~/.config/sf",
    "~/.local/share/sf",
    "~/.sf",
  ]
end
