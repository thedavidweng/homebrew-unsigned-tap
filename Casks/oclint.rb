cask "oclint" do
  minimum_macos = :monterey

  arch arm: "arm64", intel: "x86_64"

  on_sonoma :or_older do
    version "22.02"
    sha256 arm:   "b18196a459f1b30bb4b6849b5952327458671ff9f65b30c9766e8a430de23c35",
           intel: "6f102a568af3a4344f9658b5f4bdf3d599a851456287bf7a1fae447891f7368c"

    on_intel do
      binary "oclint-#{version}/include/c++/v1", target: "#{HOMEBREW_PREFIX}/include/c++/v1"
    end

    url "https://github.com/oclint/oclint/releases/download/v#{version}/oclint-#{version}-llvm-13.0.1-#{arch}-darwin-macos-12.2-xcode-13.2.tar.gz"

    livecheck do
      skip "Legacy Monterey-to-Sonoma packages are pinned; newer ARM packages use the maintained channel"
    end
  end
  on_sequoia :or_newer do
    version "24.11,16.0.5,15.1.1,16.1"
    sha256 "85062776d437bfa496df542077e6a87f88dfd7435cdbe651a01b17ed8f9df972"

    url "https://github.com/oclint/oclint/releases/download/v#{version.csv.first}/oclint-#{version.csv.first}-llvm-#{version.csv.second}-arm64-darwin-macos-#{version.csv.third}-xcode-#{version.csv.fourth}.tar.gz"

    livecheck do
      url :url
      regex(/^oclint-(\d[\d.]*)-llvm-(\d[\d.]*)-arm64-darwin-macos-(\d[\d.]*)-xcode-(\d[\d.]*)\.tar\.gz$/i)
      strategy :github_releases do |json, regex|
        json.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
          release["assets"].filter_map do |asset|
            match = asset["name"].match(regex)
            next if match.nil?

            match.captures.join(",")
          end
        end
      end
    end

    depends_on arch: :arm64
    minimum_macos = :sequoia
  end
  on_macos do
    binary "oclint-#{version.csv.first}/bin/oclint-json-compilation-database"
    binary "oclint-#{version.csv.first}/bin/oclint-xcodebuild"
    binary "oclint-#{version.csv.first}/bin/oclint"
    binary "oclint-#{version.csv.first}/lib/clang", target: "#{HOMEBREW_PREFIX}/lib/clang"
    binary "oclint-#{version.csv.first}/lib/oclint", target: "#{HOMEBREW_PREFIX}/lib/oclint"
  end

  name "OCLint"
  desc "Static source code analysis tool"
  homepage "https://github.com/oclint/oclint/"

  depends_on macos: minimum_macos

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
