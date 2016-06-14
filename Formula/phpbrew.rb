require "formula"

class Phpbrew < Formula
  desc "Brew & manage PHP versions in pure PHP at HOME"
  homepage "https://github.com/phpbrew/phpbrew"
  url "https://github.com/phpbrew/phpbrew/raw/1.22.4/phpbrew"
  sha256 "cd9e7ca6a3c0d975ec386fc803385b94726843cb44b2247e0695c699cf9e02c6"
  version "1.22.4"

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

    To start using it, please run:
    $ phpbrew init

    And also add the following command to your bash/zshrc:
    `source ~/.phpbrew/bashrc`

    Now, you can brew your own php. Take php 7.0.7 for examples:

    $ phpbrew init
    $ phpbrew lookup-prefix homebrew
    $ phpbrew install 7.0.7 +default +mysql +gettext +iconv +ftp +exif +dba +openssl +soap +apxs
    $ phpbrew switch 7.0.7
    $ phpbrew ext install gd
    $ phpbrew ext install opcache

    By default, homebrew will download formula from bottle (A precompiled binary library) if available. But If you ecounter php-gd errors in compile or execution time. Especially after upgrading your xcode. Try the following snippets.

    $ homebrew rm gd fontconfig freetype jpeg libpng libtiff xz
    $ homebrew install gd --build-from-source
    EOS
  end
end
