cask "ntfstool-commercial" do
  version "4.6.11"
  sha256 "0ff72d720506d7809fbf5931531aab1a3116154348b24963e62f57b4a1db5cd3"

  url "https://github.com/ntfstool/ntfstool/releases/download/#{version}/Ntfstool_#{version}_release.pkg"
  name "NTFSTool"
  desc "Commercial NTFS read and write utility"
  homepage "https://ntfstool.com/"

  livecheck do
    url :url
    regex(/^Ntfstool_(\d+(?:\.\d+)+)_release\.pkg$/i)
    strategy :github_latest do |json, regex|
      json["assets"].filter_map { |asset| asset["name"][regex, 1] }
    end
  end

  auto_updates true
  conflicts_with cask: "ntfstool"
  depends_on :macos

  pkg "Ntfstool_#{version}_release.pkg"

  uninstall quit:    "com.ntfstool.aile",
            pkgutil: "com.ntfstool.aile"

  caveats <<~EOS
    This is the closed-source edition with license purchases and a bundled Bright SDK.
    The open-source 3.5.1 edition remains available as ntfstool.
    Use the application's complete uninstall in Settings before removing enabled
    disk helpers, Login Items, or background services.
  EOS
end
