cask "texstudio" do
  arch arm: "-m1"

  version "4.9.5"
  sha256 arm:   "714846c3b4da8339e7128f476bbaf9f41378a21fd68f09476b027562f03ffce9",
         intel: "975d052a0e01c21a4a55007248834335357977d7dc3773c5fd91be8eba7f73eb"

  url "https://github.com/texstudio-org/texstudio/releases/download/#{version}/texstudio-#{version}-osx#{arch}.zip"
  name "TeXstudio"
  desc "LaTeX editor"
  homepage "https://texstudio.org/"


  depends_on macos: :ventura

  app "texstudio-#{version}-osx#{arch}.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/texstudio.sfl*",
    "~/Library/Preferences/texstudio.plist",
    "~/Library/Saved Application State/texstudio.savedState",
  ]
end
