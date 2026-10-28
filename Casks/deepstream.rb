cask "deepstream" do
  version "10.2.4"
  sha256 "c39fa16f7888c446c1f04394265cea4cd56593248ffc6ae5d42d5b138963d684"

  url "https://github.com/deepstreamIO/deepstream.io/releases/download/v#{version}/deepstream.io-mac-#{version}.pkg"
  name "deepstream"
  desc "Data-sync realtime server"
  homepage "https://deepstream.io/"

  depends_on arch: :arm64
  depends_on :macos

  pkg "deepstream.io-mac-#{version}.pkg"

  uninstall pkgutil: "deepstream.io"

  zap :not_required

  caveats do
    files_in_usr_local
  end
end
