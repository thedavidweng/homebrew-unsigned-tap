cask "unity-android-support-for-editor" do
  version "6000.6.11f1,34837772f4f8"
  sha256 "bc6f64decd5a80c35f64ef113081349767b180920002237b5fd78e81b3df919d"

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
