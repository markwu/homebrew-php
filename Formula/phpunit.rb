require "formula"

class Phpunit < Formula
  desc "A programmer-oriented testing framework for PHP"
  homepage "https://phpunit.de/"
  url "https://phar.phpunit.de/phpunit-5.4.8.phar"
  sha256 "7f6705f9281b5c2bc1ef2c24c8fc6d26a709ee29c5c1d1c8e600bee40f0c257c"
  version "5.4.8"

  def install
    File.rename("phpunit-5.4.8.phar", "phpunit.phar")
    libexec.install "phpunit.phar"
    (libexec/"phpunit.phar").chmod 0755
    bin.install_symlink libexec/"phpunit.phar" => "phpunit"
  end

  def caveats; <<-EOS.undent
    PHPUnit is now installed!

    To verify your installation, please run
    $ phpunit --version
    EOS
  end
end
