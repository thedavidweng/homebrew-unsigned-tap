cask "secure-pipes" do
  on_big_sur :or_older do
    version "0.99.11,c67223c50be3604"
    sha256 "de8b6ad6c42509f2c394997694c13a161dcb4f74edfa87f5a63d7362897538f5"

    url "https://www.opoet.com/pyro/index.php/files/download/#{version.csv.second}"

    livecheck do
      skip "Legacy version"
    end

    caveats do
      requires_rosetta
    end
  end
  on_monterey :or_newer do
    version "0.99.12,a813da7f43bcfc5"
    sha256 "f64cd685bde0ecae0cae77a8db432d62858e73fcd86be39ee64f01b015ad29e0"

    url "https://www.opoet.com/pyro/index.php/files/download/#{version.csv.second}"

    livecheck do
      url :homepage
      regex(/filename.*?Secure\s+Pipes\s+v?(\d+(?:\.\d+)+)\.dmg/i)
      strategy :page_match do |page, regex|
        download_hash = page.scan(%r{opoet\.com/pyro/index.php/files/download/(.+)["'< ]}i).flatten.first
        next if download_hash.blank?

        merged_headers = Homebrew::Livecheck::Strategy.page_headers(
          "https://www.opoet.com/pyro/index.php/files/download/#{download_hash}",
        ).reduce(&:merge)

        match = merged_headers["content-disposition"]&.match(regex)
        next if match.blank?

        "#{match[1]},#{download_hash}"
      end
    end
  end

  name "Secure Pipes"
  desc "Manage SSH tunnels"
  homepage "https://www.opoet.com/pyro/index.php/"

  depends_on :macos

  app "Secure Pipes.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Secure Pipes.app"],
        must_succeed: false
  end
end
