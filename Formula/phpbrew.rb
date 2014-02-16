require "formula"

class Phpbrew < Formula
  homepage "https://github.com/c9s/phpbrew"
  url "https://raw.github.com/c9s/phpbrew/master/phpbrew"
  sha1 "9abf16aae03978c4179aff60942edd558313fda7"
  version "1.13.0"

  depends_on "install"
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
  end
end
