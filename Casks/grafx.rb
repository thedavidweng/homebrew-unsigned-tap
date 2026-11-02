cask "grafx" do
  version "2.8.3174,71"
  sha256 "b0207e50bddf10e289d03ba2dd52e7fe1c5c5ee32293cc2441eb9e0aac536891"

  url "https://pulkomandy.tk/projects/GrafX#{version.major}/downloads/#{version.csv.second}"
  name "GrafX2"
  desc "256 colour painting program"
  homepage "https://pulkomandy.tk/projects/GrafX#{version.major}"

  livecheck do
    url "https://pulkomandy.tk/projects/GrafX#{version.major}/downloads"
    regex(%r{/projects/GrafX#{version.major}/downloads/(\d+)["'][^>]*>\s*Grafx\d+\.app-x86_64-sdl[._-]v?(\d+(?:\.\d+)+)\.zip}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |id, release| "#{release},#{id}" }
    end
  end

  depends_on :macos

  app "Grafx#{version.major}.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Grafx#{version.major}.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Preferences/com.googlecode.grafx2"

  caveats do
    requires_rosetta
  end
end
