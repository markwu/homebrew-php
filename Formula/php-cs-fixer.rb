require "formula"

class PhpCsFixer < Formula
  desc "PHP Coding Standards Fixer"
  homepage "http://cs.sensiolabs.org/"
  url "http://get.sensiolabs.org/php-cs-fixer.phar"
  sha256 "a7ad2a24de3fd933bd803cb64b75788520412875c864e6bf2b31ae544edad39e"
  version "1.11.4"

  def install
    libexec.install "php-cs-fixer.phar"
    (libexec/"php-cs-fixer.phar").chmod 0755
    bin.install_symlink libexec/"php-cs-fixer.phar" => "php-cs-fixer"
  end

  def caveats; <<-EOS.undent
    PHP-CS-Fixer is now installed!

    To verify your installation, please run
    $ php-cs-fixer --version
    EOS
  end
end
