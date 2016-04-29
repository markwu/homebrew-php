require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.0.2/composer.phar"
  sha256 "264673ccee900b22192605b8c74ecb77c45a5197347edacd142699866c478f4c"
  version "1.0.2"

  def install
    libexec.install "composer.phar"
    (libexec/"composer.phar").chmod 0755
    bin.install_symlink libexec/"composer.phar" => "composer"
  end

  def caveats; <<-EOS.undent
    Composer is now installed!

    To verify your installation, please run
    $ composer --version
    EOS
  end
end
