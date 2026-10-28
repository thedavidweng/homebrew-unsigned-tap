cask "salesforce-cli" do
  arch arm: "arm64", intel: "x64"

  version "2.156.8,64ad561"
  sha256 arm:   "3b97125330e337fe90d7abda53a36eac5035691fe7fc9da9d965903df34d7e1a",
         intel: "0dab41c9cf2e64995b7abd90de48182a00658ea3ae6327d53944fcd6a1cb4f2d"

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
