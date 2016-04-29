require "formula"

class Phpbrew < Formula
  desc "Brew & manage PHP versions in pure PHP at HOME"
  homepage "https://github.com/phpbrew/phpbrew"
  url "https://github.com/phpbrew/phpbrew/raw/1.21.1/phpbrew"
  sha256 "bbad349681684a921a4a5b24c9bb361e19d1e0d30720955d945394ced57b3570"
  version "1.21.1"

  depends_on "autoconf"
  depends_on "automake"
  depends_on "curl"
  depends_on "gd"
  depends_on "gettext"
  depends_on "gmp"
  depends_on "icu4c"
  depends_on "bison"
  depends_on "jpeg"
  depends_on "libevent"
  depends_on "libtool"
  depends_on "libxml2"
  depends_on "mcrypt"
  depends_on "mhash"
  depends_on "openssl"
  depends_on "pcre"
  depends_on "re2c"

  def install
    libexec.install "phpbrew"
    (libexec/"phpbrew").chmod 0755
    bin.install_symlink  libexec/"phpbrew"
  end

  def caveats; <<-EOS.undent
    PHPBrew is now installed!

    Make sure icu4c, bison, openssl, libxml2 is linked before using phpbrew. Run following command to relink.
    $ brew unlink icu4c && brew link icu4c --force
    $ brew unlink bison && brew link bison --force
    $ brew unlink openssl && brew link openssl --force
    $ brew unlink libxml2 && brew link libxml2 --force

    To start using it, please run:
    $ phpbrew init

    And also add the following command to your bash/zshrc:
    `source ~/.phpbrew/bashrc`

    Now, you can brew your own php. Take php 5.5.17 for examples:

    $ phpbrew init
    $ phpbrew lookup-prefix homebrew
    $ phpbrew install 5.6.20 +default +mysql +gettext=/usr/local/opt/gettext +iconv +ftp +exif +dba +openssl +soap +apxs2=/usr/local/bin/apxs
    $ phpbrew switch 5.6.20
    $ phpbrew ext install gd
    $ phpbrew ext install opcache

    By default, homebrew will download formula from bottle (A precompiled binary library) if available. But If you ecounter php-gd errors in compile or execution time. Especially after upgrading your xcode. Try the following snippets.

    $ phpberw rm gd fontconfig freetype jpeg libpng libtiff xz
    $ phpbrew install gd --build-from-source
    EOS
  end
end
