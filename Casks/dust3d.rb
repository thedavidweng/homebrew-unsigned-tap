cask "dust3d" do
  version "1.1.6"
  sha256 "d224bdb3a948ed40ae84a4c923607afff5f54a636fbde27622b98e7dde222022"

  url "https://github.com/huxingyi/dust3d/releases/download/#{version}/dust3d-#{version}.dmg"
  name "Dust3D"
  desc "Open-source 3D modelling software"
  homepage "https://dust3d.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end


  depends_on :macos

  app "dust3d.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Saved Application State/com.yourcompany.dust3d.savedState"
end
