cask "codelite" do
  version "18.4.0,macOS_26.4.1-arm64"
  sha256 "395e227230446d8274767ef274f67a7ca087da2af1b61366b0548259b7949a11"

  url "https://downloads.codelite.org/codelite/#{version.csv.first}/codelite-#{version.csv.second}.app.tar.gz"
  name "CodeLite"
  desc "IDE for C, C++, PHP and Node.js"
  homepage "https://codelite.org/"

  livecheck do
    url "https://raw.githubusercontent.com/eranif/homebrew-codelite/main/Casks/codelite-official.rb"
    regex(/else\s+version\s+"(\d+(?:\.\d+)+)"\s+filename\s*=\s*"codelite-([^"\s]+)\.app\.tar\.gz"/m)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| "#{match[0]},#{match[1]}" }
    end
  end

  conflicts_with cask: "codelite@legacy"
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "codelite.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/codelite.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/codelite",
    "~/Library/Preferences/codelite.plist",
  ]

  caveats do
    "This CodeLite ARM binary requires macOS 15.5 or later."
  end
end
