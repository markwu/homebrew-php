require "formula"

class Phpbrew < Formula
  homepage "https://github.com/c9s/phpbrew"
  url "https://raw.github.com/c9s/phpbrew/master/phpbrew"
  sha1 "c8895d483c0141fd22caf27b1bed32f1b0003628"
  version "1.13.1"

  resource 'sh' do
    url "https://raw.github.com/c9s/phpbrew/master/phpbrew.sh"
    sha1 "55f6a8c502195fcf882e2fa39113e33d3b99f0af"
  end

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
    chmod 0755, libexec + "phpbrew"

    mkdir HOMEBREW_PREFIX + "phpbrew"

    init = prefix + "init"
    init.write("export PHPBREW_HOME=#{HOMEBREW_PREFIX}/phpbrew\nexport PHPBREW_ROOT=#{HOMEBREW_PREFIX}/phpbrew\nexport PHPBREW_LOOKUP_PREFIX=#{HOMEBREW_PREFIX}/Cellar:#{HOMEBREW_PREFIX}")

    prefix.install resource('sh')
    mv prefix + "phpbrew.sh", prefix + "bashrc"

    phpbrew_main = prefix + "phpbrew"
    phpbrew_main.write("#!/usr/bin/env bash\n\nsource #{prefix}/init\nsource #{prefix}/bashrc\n\nexport PATH=$PHPBREW_BIN:$PATH")

    phpbrew = bin + "phpbrew"
    phpbrew.write("#!/usr/bin/env bash\n\nphp #{libexec}/phpbrew $*")

    puts "\033[00;32m"
    puts "##################################"
    puts "phpbrew is now installed"
    puts "To start using it, please run `source $(brew --prefix)/opt/phpbrew/phpbrew`"
    puts "We also recommand you to add this command to your bash/zshrc"
    puts "##################################"
    puts "\033[0m"
  end
end
