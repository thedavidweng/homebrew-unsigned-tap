cask "catchup-e2e-fixture" do
  on_arm do
    version "1.0"
  end
  on_intel do
    version "1.4"
  end
  sha256 :no_check
  url "https://example.test/#{version}.zip"
  name "Catchup test fixture"
  desc "Temporary automation test fixture"
  homepage "https://example.test/"
  depends_on :macos
  binary "fixture"
end
