cask "alipay-key-tool" do
  version "2.0.4"
  sha256 :no_check

  url "https://ideservice.alipay.com/ide/getPluginUrl.htm?clientType=assistant&platform=mac&channelType=WEB"
  name "Alipay Open Platform Key Tool"
  desc "Key generation tool"
  homepage "https://opendocs.alipay.com/common/02kipk"

  livecheck do
    skip "version is shown in screenshot on homepage"
  end


  depends_on :macos

  app "支付宝开放平台密钥工具.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/alipaykeytool",
    "~/Library/Preferences/com.alipay.alipayleytool.plist",
    "~/Library/Saved Application State/com.alipay.alipayleytool.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
