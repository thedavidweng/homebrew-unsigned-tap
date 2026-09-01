cask "displaycal" do
  version "3.8.9.3"
  sha256 "3e3f4a506c3ffc1e2004d57c6cd521d6cacb1bb6a71f9e3fa4cd81ab6ad4f31a"

  url "https://downloads.sourceforge.net/dispcalgui/release/#{version}/DisplayCAL-#{version}.pkg"
  name "DisplayCAL"
  desc "Display calibration and characterization powered by ArgyllCMS"
  homepage "https://displaycal.net/"

  livecheck do
    url "https://sourceforge.net/projects/dispcalgui/rss?path=/release"
  end


  auto_updates true
  depends_on :macos
  depends_on formula: "argyll-cms"

  pkg "DisplayCAL-#{version}.pkg"

  uninstall pkgutil: "net.displaycal.*.DisplayCAL.*"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/dispcalGUI",
    "~/Library/Application Support/DisplayCAL",
    "~/Library/Logs/dispcalGUI",
    "~/Library/Logs/DisplayCAL",
    "~/Library/Preferences/dispcalGUI",
    "~/Library/Preferences/DisplayCAL",
  ]

  caveats do
    requires_rosetta
    <<~EOS
      If #{token} asks for argyll-cms, do not choose to download.
      Instead, select "Browse" and point #{token} to your #{HOMEBREW_PREFIX}/bin.
    EOS
  end
end
