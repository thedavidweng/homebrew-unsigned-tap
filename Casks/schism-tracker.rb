cask "schism-tracker" do
  version "20260524"
  sha256 "c4f389b52bb6d60a4a004c5db9bbbcdecb8b8a5a086f45c2aa31c4f1df51333d"

  url "https://github.com/schismtracker/schismtracker/releases/download/#{version}/schismtracker-#{version}-macos.zip"
  name "Schism Tracker"
  desc "Oldschool sample-based music composition tool"
  homepage "https://github.com/schismtracker/schismtracker"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)*)$/i)
  end


  depends_on macos: :big_sur

  app "Schism Tracker.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Schism Tracker",
    "~/Library/Saved Application State/org.schismtracker.SchismTracker.savedState",
  ]
end
