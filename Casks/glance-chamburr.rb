cask "glance-chamburr" do
  on_ventura :or_older do
    version "1.5.4"
    sha256 "f2df114e83b8b834c2da9d4cfbd4d3307a8f0563a9e613bfdd88b4b3bffe61ad"

    livecheck do
      skip "Legacy release for macOS Ventura and older"
    end
  end
  on_sonoma :or_newer do
    version "1.6.0"
    sha256 "c18639a8eeaad15d5207fb77ae59574839fecbd6d7f7e204a53a4451500a20cf"
  end

  url "https://github.com/chamburr/glance/releases/download/v#{version}/Glance-#{version}.dmg"
  name "Glance"
  desc "Utility to provide quick look previews for files that aren't natively supported"
  homepage "https://github.com/chamburr/glance"

  depends_on :macos

  app "Glance.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Glance.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Scripts/com.chamburr.Glance",
    "~/Library/Application Scripts/com.chamburr.Glance.QLPlugin",
    "~/Library/Containers/com.chamburr.Glance",
    "~/Library/Containers/com.chamburr.Glance.QLPlugin",
  ]

  caveats <<~EOS
    You must start #{appdir}/Glance.app once manually to setup the Quick Look plugin.
  EOS
end
