cask "unity-android-support-for-editor" do
  version "6000.6.9f1,8c45277fb9c5"
  sha256 "cab79ee1945e5612ffa91f15ff5f6e54e2860d89c5a5fcd0d6578f700ea5e8cd"

  url "https://download.unity3d.com/download_unity/#{version.csv.second}/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-#{version.csv.first}.pkg"
  name "Unity Android Build Support"
  desc "Android target support for Unity"
  homepage "https://unity.com/products"

  livecheck do
    url "https://services.api.unity.com/unity/editor/release/v1/releases?platform=MAC_OS&stream=SUPPORTED&architecture=ARM64&limit=1&offset=0"
    regex(%r{/(\h+)/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-(\d+(?:\.\d+)+(?:f\d+)?)\.pkg}i)
    strategy :json do |json, regex|
      json["results"].flat_map do |release|
        release["downloads"].flat_map do |download|
          download["modules"].filter_map do |mod|
            next if mod["id"] != "android"

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
