cask "unity-android-support-for-editor" do
  version "6000.6.5f1,3ff58d469c8a"
  sha256 "2ef6c30da644ec13579216201d3a8be967e8c772ff4fa0e4c59a8f65217c7b5b"

  url "https://download.unity3d.com/download_unity/#{version.csv.second}/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-#{version.csv.first}.pkg"
  name "Unity Android Build Support"
  desc "Android target support for Unity"
  homepage "https://unity.com/products"

  livecheck do
    url "https://services.api.unity.com/unity/editor/release/v1/releases?platform=MAC_OS&stream=SUPPORTED&architecture=ARM64&limit=1&offset=0"
    regex(%r{/(\h+)/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor[._-]v?(\d+(?:\.\d+)+(?:f\d+)?)\.pkg}i)
    strategy :json do |json, regex|
      json["results"].flat_map do |release|
        release["downloads"].flat_map do |download|
          download["modules"].filter_map do |mod|
            next unless mod["id"] == "android"

            match = mod["url"].match(regex)
            "#{match[2]},#{match[1]}" if match
          end
        end
      end
    end
  end

  depends_on cask: "unity"
  depends_on :macos

  pkg "UnitySetup-Android-Support-for-Editor-#{version.csv.first}.pkg"

  uninstall pkgutil: "com.unity3d.AndroidPlayer-#{version.csv.first}"
end
