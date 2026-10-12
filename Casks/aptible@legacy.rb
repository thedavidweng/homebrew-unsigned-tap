cask "aptible@legacy" do
  version "0.26.8,20260608224702,gh-89"
  sha256 "0abe0783430ea31172064535eb9a79bd3ecbab1f4a4aacb59f257eee251ef554"

  url "https://omnibus-aptible-toolbelt.s3.amazonaws.com/aptible/omnibus-aptible-toolbelt/master/#{version.csv.third}/pkg/aptible-toolbelt-#{version.csv.first}%2B#{version.csv.second}-mac-os-x.10.15.7-1.pkg"
  name "Aptible Toolbelt (Legacy)"
  desc "Command-line tool for Aptible Deploy, an audit-ready App Deployment Platform"
  homepage "https://www.aptible.com/docs/reference/aptible-cli/overview"

  livecheck do
    skip "Legacy Ruby Toolbelt is pinned; use aptible for maintained Go CLI updates"
  end

  conflicts_with cask: "aptible"
  depends_on formula: "libfido2"
  depends_on :macos

  pkg "aptible-toolbelt-#{version.csv.first}+#{version.csv.second}-mac-os-x.10.15.7-1.pkg"

  uninstall pkgutil: "com.aptible.toolbelt"

  zap trash: "/usr/local/bin/aptible"

  caveats <<~EOS
    This preserves the legacy Ruby Toolbelt without automatic updates.
    Use aptible for the maintained Go CLI on macOS Monterey or later.
  EOS
end
