cask "eloquent" do
  version "2.6.8"
  sha256 "9dad39e05f0acf2384a1157f138974e199265c4aefb26e73c4530fec7a96d5a2"

  url "https://github.com/mdbergmann/Eloquent/releases/download/#{version}/Eloquent-#{version}.app.zip"
  name "Eloquent"
  desc "Free/open-source Bible study application, based on the SWORD Project"
  homepage "https://github.com/mdbergmann/Eloquent"

  auto_updates true
  depends_on macos: :ventura

  app "Eloquent.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Eloquent",
    "~/Library/Logs/Eloquent.log",
    "~/Library/Preferences/org.crosswire.Eloquent.plist",
    "~/Library/Preferences/org.crosswire.Eloquent.plist.lockfile",
    "~/Library/Saved Application State/org.crosswire.Eloquent.savedState",
  ]
end
