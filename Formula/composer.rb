require "formula"

class Composer < Formula
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"
  url "https://getcomposer.org/download/1.0.0-alpha9/composer.phar"
  sha1 "c0917158e84c867ce69753fcbc04eb7c45bb58bb"
  version "1.0.0-alpha9"

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
