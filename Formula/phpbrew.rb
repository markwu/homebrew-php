require "formula"

class Phpbrew < Formula
  desc "Brew & manage PHP versions in pure PHP at HOME"
  homepage "https://github.com/phpbrew/phpbrew"
  url "https://github.com/phpbrew/phpbrew/raw/1.22.7/phpbrew"
  sha256 "4433872ac70ace6ab73ae1c483aa13951c962b6a6727c11bce5c6325e04fec7c"
  version "1.22.7"

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

    Now, you can brew your own php. Take php 7.1.5 for examples:

    $ phpbrew init
    $ phpbrew lookup-prefix homebrew
    $ phpbrew install 7.1.5 +default +dbs +dba +openssl +apxs2
    $ phpbrew switch 7.1.5
    $ phpbrew ext install gettext -- --with-gettext=/usr/local/opt/gettext && phpbrew ext install iconv && phpbrew ext install ftp -- --with-openssl-dir=/usr/local/opt/openssl && phpbrew ext install exif && phpbrew ext install soap && phpbrew ext install gd -- --with-gd=shared && phpbrew ext install opcache && phpbrew ext install xdebug

    or, you can brew most extensions with php core together

    $ phpbrew install 7.1.5 +default +dbs +dba +gettext +iconv +ftp +exif +openssl +soap +apxs2 +opcache +gd=shared

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
