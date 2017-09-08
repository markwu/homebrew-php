require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.5.1/composer.phar"
  sha256 "2745e7b8cced2e97f84b9e9cb0f9c401702f47cecea5a67f095ac4fa1a44fb80"
  version "1.5.1"

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
