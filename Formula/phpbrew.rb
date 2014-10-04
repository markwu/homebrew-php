require "formula"

class Phpbrew < Formula
  homepage "https://github.com/phpbrew/phpbrew"
  head "https://github.com/phpbrew/phpbrew/blob/master/phpbrew?raw=true"
  url "https://github.com/phpbrew/phpbrew/blob/1.14.2/phpbrew?raw=true"
  sha1 "f4a1240fa73f9bf575137fbb4aabfe79530e9cdb"
  version "1.14.2"

  depends_on "autoconf"
  depends_on "automake"
  depends_on "curl"
  depends_on "gd"
  depends_on "gettext"
  depends_on "gmp"
  depends_on "icu4c"
  depends_on "jpeg"
  depends_on "libevent"
  depends_on "libtool"
  depends_on "libxml2"
  depends_on "mcrypt"
  depends_on "mhash"
  depends_on "pcre"
  depends_on "re2c"

  def install
    libexec.install "phpbrew"
    (libexec/"phpbrew").chmod 0755
    bin.install_symlink  libexec/"phpbrew"
  end

  def caveats; <<-EOS.undent
    phpbrew is now installed!

    Make sure icu4c is linked before using phpbrew. Run following command to relink.
    $ brew unlink icu4c && brew link icu4c --force

    To start using it, please run:
    $ phpbrew init

    And also add the following command to your bash/zshrc:
    `source ~/.phpbrew/bashrc`

    Now, you can brew your own php. Take php 5.5.17 for examples:

    $ phpbrew init
    $ phpbrew install 5.5.17 +default +mysql +gettext=/usr/local/opt/gettext +iconv +ftp +exif +dba +openssl +soap +apxs2=/usr/local/bin/apxs
    $ phpbrew switch 5.5.17
    $ phpbrew ext install gd
    $ phpbrew ext install opcache

    By default, homebrew will download formula from bottle (A precompiled binary library) if available. But If you ecounter php-gd errors in compile or execution time. Especially after your upgrade your xcode. Try the following snippets.

    $ phpberw rm gd fontconfig freetype jpeg libpng libtiff xz
    $ phpbrew install gd --build-from-source
    EOS
  end
end
