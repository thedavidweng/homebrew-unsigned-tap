cask "protege" do
  version "5.6.9"
  sha256 "a3037b38dbdbf8c4cb49ae6d883542c93a9c5f58f17b5c3121b44dee29a428e7"

  url "https://github.com/protegeproject/protege-distribution/releases/download/protege-#{version}/Protege-#{version}-mac.zip"
  name "Protégé"
  desc "Ontology editor"
  homepage "https://protege.stanford.edu/"

  depends_on macos: :big_sur

  app "Protege-#{version}/Protégé.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.Protege",
    "~/Library/Preferences/protege_preferences.*",
    "~/Library/Saved Application State/edu.stanford.protege.savedState",
  ]
end
