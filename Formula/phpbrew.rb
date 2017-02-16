require "formula"

class Phpbrew < Formula
  desc "Brew & manage PHP versions in pure PHP at HOME"
  homepage "https://github.com/phpbrew/phpbrew"
  url "https://github.com/phpbrew/phpbrew/raw/1.22.6/phpbrew"
  sha256 "efe2fc91ec92f1ff00fb37fa7d8fc7a14979ac81ed23c239cc6961e05e18d970"
  version "1.22.6"

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

    Now, you can brew your own php. Take php 7.0.9 for examples:

    $ phpbrew init
    $ phpbrew lookup-prefix homebrew
    $ phpbrew install 7.1.1 +default +dbs +dba +gettext +iconv +ftp +exif +openssl +soap +apxs2
    $ phpbrew switch 7.1.1
    $ phpbrew ext install gd
    $ phpbrew ext install opcache
    $ phpbrew ext install xdebug

    or, you can brew gd and opcache extensions with php core together

    $ phpbrew install 7.1.1 +default +dbs +dba +gettext +iconv +ftp +exif +openssl +soap +apxs2 +gd +opcache -- --with-gd=shared

    NOTE:

    By default, homebrew will install packages from bottle first (A precompiled binary package). If you ecounter php-gd errors in compile or execution time, especially after upgrading your xcode. Try the following snippets.

    Remove GD and dependency
    $ homebrew uninstall gd fontconfig freetype jpeg libpng libtiff xz

    Install GD from bottle again
    $ homebrew install gd

    Or build GD from source
    $ homebrew install gd --build-from-source
    EOS
  end
end
