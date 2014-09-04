require "formula"

class Phpbrew < Formula
  homepage "https://github.com/phpbrew/phpbrew"
  head "https://github.com/phpbrew/phpbrew/blob/master/phpbrew?raw=true"
  url "https://github.com/phpbrew/phpbrew/blob/1.14.0/phpbrew?raw=true"
  sha1 "364c9d8cc0fcecb89f272695444a9b4f9d0d199d"
  version "1.14.0"

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
    libexec.install "phpbrew"
    (libexec/"phpbrew").chmod 0755
    bin.install_symlink  libexec/"phpbrew"
  end

  def caveats; <<-EOS.undent
    phpbrew is now installed!

    Make sure icu4c is linked before using phpbrew. Run following command to relink.
      `brew unlink icu4c && brew link icu4c --force`

    To start using it, please run
      `phpbrew init`

    And also add the following command to your bash/zshrc
      `source ~/.phpbrew/bashrc`
    EOS
  end
end
