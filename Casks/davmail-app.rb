cask "davmail-app" do
  version "7.1.0,4498"
  sha256 "4b1ed4467e1b3cf6a48f365d648dce08e2761f92f9ac3af5e5f1c976b919cb89"

  url "https://downloads.sourceforge.net/davmail/DavMail-MacOSX-#{version.csv.first}-#{version.csv.second}.app.zip"
  name "DavMail"
  desc "Use any mail/calendar client with an Exchange server"
  homepage "https://davmail.sourceforge.net/"

  livecheck do
    url "https://sourceforge.net/projects/davmail/rss?path=/davmail"
    regex(%r{url=.*?/DavMail-MacOSX[._-]v?(\d+(?:\.\d+)+)-(\d+(?:\.\d+)*)\.app\.zip}i)
    strategy :sourceforge do |page, regex|
      page.scan(regex).map { |match| "#{match[0]},#{match[1]}" }
    end
  end

  depends_on :macos

  app "DavMail.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/DavMail.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.davmail.properties",
    "~/Library/Logs/DavMail",
  ]

  caveats do
    depends_on_java
  end
end
