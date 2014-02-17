require "formula"

class Phpbrew < Formula
  homepage "https://github.com/c9s/phpbrew"
  url "https://raw.github.com/c9s/phpbrew/master/phpbrew"
  sha1 "9abf16aae03978c4179aff60942edd558313fda7"
  version "1.13.0"

  devel do
    url "https://raw.github.com/c9s/phpbrew/develop/phpbrew"
    sha1 "a8c7efafdeb7379a9a7b346897c9f8269d64b560"
    version "1.13.0-devel"
  end

  resource 'sh' do
    url "https://raw.github.com/c9s/phpbrew/master/phpbrew.sh"
    sha1 "55f6a8c502195fcf882e2fa39113e33d3b99f0af"
  end

  resource 'sh-devel' do
    url "https://raw.github.com/c9s/phpbrew/develop/phpbrew.sh"
    sha1 "cdd4cc7c50218dcae01c8dd237c9b71f9d5febf7"
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
    bin.install "phpbrew"
    chmod 0755, bin + "phpbrew"

    init = prefix + "init"
    init.write("export PHPBREW_HOME=" + prefix + "\nexport PHPBREW_ROOT=" + prefix + "\nexport PHPBREW_LOOKUP_PREFIX=" + HOMEBREW_PREFIX + "/Cellar:" + HOMEBREW_PREFIX)

    if build.devel?
      prefix.install resource('sh-devel')
    else
      prefix.install resource('sh')
    end
    mv prefix + "phpbrew.sh", prefix + "bashrc"

    phpbrew_main = prefix + "phpbrew"
    phpbrew_main.write("#!/usr/bin/env bash\n\nsource " + prefix + "/init\nsource " + prefix + "/bashrc")

    puts "\033[00;32m"
    puts "##################################"
    puts "phpbrew is now installed"
    puts "To start using it, please run `source $(brew --prefix)/opt/phpbrew/phpbrew`"
    puts "We also recommand you to add this command to your bash/zshrc"
    puts "##################################"
    puts "\033[0m"
  end
end
