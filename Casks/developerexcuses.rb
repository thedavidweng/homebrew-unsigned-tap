cask "developerexcuses" do
  on_intel do
    version "2.1.3"
    sha256 "e1fe0105be02de196bbae04051abd506bfa2ac7a2c3ba5f9922c70700a2d61b3"

    livecheck do
      skip "Pinned to the last version with an Intel binary"
    end
  end
  on_arm do
    version "2.1.4"
    sha256 "cbcee9d430a707f0b1b6187392af038ea8d8a5602a05a6d327dc54b4d01ab657"

    livecheck do
      url :url
      strategy :github_latest
    end
  end

  url "https://github.com/kimar/DeveloperExcuses/releases/download/#{version}/DeveloperExcuses.saver.zip"
  name "Developer Excuses Screensaver"
  desc "Screensaver showing quotes from developerexcuses.com"
  homepage "https://github.com/kimar/DeveloperExcuses"

  depends_on :macos

  screen_saver "DeveloperExcuses.saver"

  # No zap stanza required

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end
end
