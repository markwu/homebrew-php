require "formula"

class Phpunit < Formula
  desc "A programmer-oriented testing framework for PHP"
  homepage "https://phpunit.de/"
  url "https://phar.phpunit.de/phpunit-5.3.4.phar"
  sha256 "ce354a3722dd40f2af807e6ddc091646b7364b14f639a1fdd077e1c95f8ad859"
  version "5.3.4"

  def install
    File.rename("phpunit-5.3.4.phar", "phpunit.phar")
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
