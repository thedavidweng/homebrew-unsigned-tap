cask "milkman" do
  version "5.12.0"
  sha256 "2c7b037d82d40ecf1465b9e09f6fef3da3ca1a1a090e751cfbb94d51473ade0f"

  url "https://github.com/warmuuh/milkman/releases/download/#{version}/milkman-dist-appbundle-macos64-bin.tgz"
  name "Milkman"
  desc "Extensible request and response workbench"
  homepage "https://github.com/warmuuh/milkman"

  livecheck do
    url :url
    regex(/^(\d+(?:\.\d+)+)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"] || release["prerelease"]
        next unless release["assets"].any? { |asset| asset["name"] == "milkman-dist-appbundle-macos64-bin.tgz" }

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  depends_on :macos

  app "Milkman.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Milkman.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Application Support/Milkman"
end
