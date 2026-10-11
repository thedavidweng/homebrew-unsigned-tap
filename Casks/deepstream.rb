cask "deepstream" do
  version "10.2.3"
  sha256 "01934a155853dd0247707f505a788fb5dbe44b370265b92e7dfc8c5fdf1b20ac"

  url "https://github.com/deepstreamIO/deepstream.io/releases/download/v#{version}/deepstream.io-mac-#{version}.pkg"
  name "deepstream"
  desc "Data-sync realtime server"
  homepage "https://deepstream.io/"

  depends_on :macos

  pkg "deepstream.io-mac-#{version}.pkg"

  uninstall pkgutil: "deepstream.io"

  # No zap stanza required

  caveats do
    files_in_usr_local
  end
end
