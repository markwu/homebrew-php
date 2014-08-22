require "formula"

class Phpbrew < Formula
  homepage "https://github.com/phpbrew/phpbrew"
  head "https://github.com/phpbrew/phpbrew/blob/master/phpbrew?raw=true"
  url "https://github.com/phpbrew/phpbrew/blob/1.13.2/phpbrew?raw=true"
  sha1 "89a730ba23f255299bcfeba83da7297042079bab"
  version "1.13.2"

  depends_on "automake"
  depends_on "autoconf"
  depends_on "curl"
  depends_on "pcre"
  depends_on "re2c"
  depends_on "mhash"
  depends_on "libtool"
  depends_on "icu4c"
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libxml2"
  depends_on "mcrypt"
  depends_on "gmp"
  depends_on "libevent"

  def install
    system "chmod a+x phpbrew"
    system "mkdir -p #{prefix}/bin"
    system "cp phpbrew #{prefix}/bin"
  end

  def caveats; <<-EOS.undent
    phpbrew is now installed!

    To start using it, please run
      `source $(brew --prefix)/opt/phpbrew/phpbrew`

    We also recommand you to add this command to your bash/zshrc
    EOS
  end
end
