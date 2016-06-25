require "formula"

class Phpunit < Formula
  desc "A programmer-oriented testing framework for PHP"
  homepage "https://phpunit.de/"
  url "https://phar.phpunit.de/phpunit-5.4.6.phar"
  sha256 "f1aa125103a91f573ed43bb8fea42b5e087e5d67d570e84cb4ab2215a40ecbf8"
  version "5.4.6"

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
