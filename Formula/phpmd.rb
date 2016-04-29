require "formula"

class Phpmd < Formula
  desc "PHP Mess Dector"
  homepage "http://phpmd.org"
  url "http://static.phpmd.org/php/2.4.3/phpmd.phar"
  sha256 "0479a34ddac69cd7ed9aa9f6cde9b53c7cb5643405745aa1625b770d9edd01b1"
  version "2.4.3"

  def install
    libexec.install "phpmd.phar"
    (libexec/"phpmd.phar").chmod 0755
    bin.install_symlink libexec/"phpmd.phar" => "phpmd"
  end

  def caveats; <<-EOS.undent
    PHPMD is now installed!

    To verify your installation, please run
    $ phpmd --version
    EOS
  end
end
