cask "salesforce-cli" do
  arch arm: "arm64", intel: "x64"

  version "2.155.8,0e9b02e"
  sha256 arm:   "1ebc1c17df7ba2163ab9580b280060b637b7a1e05230e16fa6bd1155e601c4b8",
         intel: "3d28d0b2c771626bb6888c0da7ae47971f13a4432a02d4678fe1616323e26a43"

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
