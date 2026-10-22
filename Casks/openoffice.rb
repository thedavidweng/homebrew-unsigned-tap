cask "openoffice" do
  version "4.1.17"

  language "en", default: true do
    sha256 "6fc33dadacf4d0537b6fac71342fc1fbdc58f1def134ffa0682095925f12cdbf"
    "en-US"
  end
  language "de" do
    sha256 "8c2033867ccd02c709499a47923f465b10e8b6291fff3b437c197b6d30c22d56"
    "de"
  end
  language "fr" do
    sha256 "4358d9a9fbcfca5d4576d87f5d44354c371e420721fe8db4fa1f6ec5e022db5f"
    "fr"
  end
  language "gl" do
    sha256 "2d5dbb170488b21125e872c367eb39f0e51cf3bafe7d75d55d341085e5b5e02c"
    "gl"
  end
  language "ko" do
    sha256 "a2a0fa6a41577006ad43f416c5e577780b8e35857f839cd66adc22c8ac8858b4"
    "ko"
  end
  language "pt-BR" do
    sha256 "84fab51a9f58dae3f0e27dc94e541fb7a8c27d2eb23b50083ad6629e6516eceb"
    "pt-BR"
  end
  language "pt" do
    sha256 "e3ae6fc376e13cbd5dd846e38f7ebeb2985c1608dbba29e1bcbf3328fb7e8583"
    "pt"
  end
  language "ru" do
    sha256 "3f597f8c5ff8a2552a07d9a863d73e04c70f9861702b6010583328008014f1d9"
    "ru"
  end

  url "https://downloads.sourceforge.net/openofficeorg.mirror/Apache_OpenOffice_#{version}_MacOS_x86-64_install_#{language}.dmg"
  name "Apache OpenOffice"
  desc "Free and open-source productivity suite"
  homepage "https://www.openoffice.org/"

  depends_on :macos

  app "OpenOffice.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/OpenOffice.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Application Support/OpenOffice"

  caveats do
    requires_rosetta
  end
end
