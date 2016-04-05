require "formula"

class Composer < Formula
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"
  url "https://getcomposer.org/download/1.0.0/composer.phar"
  sha256 "1acc000cf23bd9d19e1590c2edeb44fb915f88d85f1798925ec989c601db0bd6"
  version "1.0.0"

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
