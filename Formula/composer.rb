require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.8.0/composer.phar"
  sha256 "0901a84d56f6d6ae8f8b96b0c131d4f51ccaf169d491813d2bcedf2a6e4cefa6"
  version "1.6.3"

  def install
    libexec.install "composer.phar"
    (libexec/"composer.phar").chmod 0755
    bin.install_symlink libexec/"composer.phar" => "composer"
  end

  def caveats; <<~EOS
    Composer is now installed!

    To verify your installation, please run
    $ composer --version
    EOS
  end
end
