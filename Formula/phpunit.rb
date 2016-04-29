require "formula"

class Phpunit < Formula
  desc "A programmer-oriented testing framework for PHP"
  homepage "https://phpunit.de/"
  url "https://phar.phpunit.de/phpunit-5.3.2.phar"
  sha256 "3af5c42ef7aae5ff8f26ae72390b3e758ac2076feedba7fd5a4c2f1efd4f004e"
  version "5.3.2"

  def install
    File.rename("phpunit-5.3.2.phar", "phpunit.phar")
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
