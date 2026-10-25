cask "isabelle" do
  version "2026"
  sha256 "ac750bf2a124005109df686177405551c9c3a61ad0d1064d5958b0a27af3f079"

  url "https://www.cl.cam.ac.uk/research/hvg/Isabelle/dist/Isabelle#{version}_macos.tar.gz"
  name "Isabelle"
  desc "Generic proof assistant"
  homepage "https://www.cl.cam.ac.uk/research/hvg/Isabelle/"

  livecheck do
    url :homepage
    regex(/href=.*?Isabelle[._-]?v?(\d+(?:[.-]\d+)*)[._-]macos\.t/i)
  end

  depends_on :macos

  binary "#{appdir}/Isabelle#{version}.app/bin/isabelle"
  artifact "Isabelle#{version}.app", target: "#{appdir}/Isabelle#{version}.app"

  # No zap stanza required

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end
end
