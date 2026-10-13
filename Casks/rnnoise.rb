cask "rnnoise" do
  on_ventura :or_older do
    version "1.03"
    sha256 "544d1daef1c32e2e5bbb2f43eda1c5f2619f2a9e755721ee26366b5eda9e2668"

    livecheck do
      skip "Pinned to the last version compatible with macOS 13 and earlier"
    end
  end
  on_sonoma :or_newer do
    version "1.10"
    sha256 "53c41fe3ce8af529b1d2d18802ecbd7e9f0b6d7ad013fd5f92f6af974472a9e9"

    livecheck do
      url :url
      strategy :github_latest
    end
  end

  url "https://github.com/werman/noise-suppression-for-voice/releases/download/v#{version}/macos-rnnoise.zip"
  name "Noise Suppression for Voice"
  desc "Real-time Noise Suppression Plugin"
  homepage "https://github.com/werman/noise-suppression-for-voice"

  depends_on :macos

  audio_unit_plugin "macos-rnnoise/rnnoise.component"
  vst_plugin "macos-rnnoise/vst/rnnoise_mono.vst"
  vst_plugin "macos-rnnoise/vst/rnnoise_stereo.vst"
  vst3_plugin "macos-rnnoise/rnnoise.vst3"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap rmdir: [
    "~/Library/Audio/Plug-Ins/VST",
    "~/Library/Audio/Plug-Ins/VST3",
  ]
end
