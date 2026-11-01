cask "catchup-e2e-fixture" do
  version "1.5"
  sha256 :no_check
  url "https://example.test/#{version}.zip"
  name "Catchup test fixture"
  desc "Temporary automation test fixture"
  homepage "https://example.test/"
  depends_on :macos
  binary "fixture"
end
