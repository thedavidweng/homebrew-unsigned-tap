cask "xournal++" do
  arch arm: "ARM64", intel: "X64"

  version "1.3.8"
  sha256 arm:   "7d992ef097afd6db304cb9df70615e67f1a1de412e06f7dc8f907fcde3b7d6d7",
         intel: "e61a58f9dea32805f87c9a0310aa319809a1045b06600afc0a55e79a097cc4eb"

  url "https://github.com/xournalpp/xournalpp/releases/download/v#{version}/xournalpp-#{version}-macOS-#{arch}.dmg"
  name "Xournal++"
  desc "Handwriting notetaking software"
  homepage "https://github.com/xournalpp/xournalpp"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Xournal++.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Xournal++.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.xournalpp",
    "~/Library/Saved Application State/com.github.xournalpp.savedState",
  ]
end
