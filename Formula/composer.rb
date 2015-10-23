require "formula"

class Composer < Formula
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"
  url "https://getcomposer.org/download/1.0.0-alpha10/composer.phar"
  sha1 "5913d2b2a0cb07e9a2d620bd1f66340ec676e28a"
  version "1.0.0-alpha10"

  def install
    libexec.install "composer.phar"
    (libexec/"composer.phar").chmod 0755
    bin.install_symlink libexec/"composer.phar" => "composer"
  end

  def caveats; <<-EOS.undent
    composer is now installed!

    To verify your installation, please run
    $ composer --version
    EOS
  end
end
