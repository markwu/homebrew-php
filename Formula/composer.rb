require "formula"

class Composer < Formula
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"
  url "https://getcomposer.org/download/1.0.0-beta2/composer.phar"
  sha256 "128f8c7ad49a71e4abda885ca52c603e370d5cbed85479ae1eab4a58a398a6a4"
  version "1.0.0-beta2"

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
