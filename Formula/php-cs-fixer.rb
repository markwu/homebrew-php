require "formula"

class PhpCsFixer < Formula
  desc "PHP Coding Standards Fixer"
  homepage "http://cs.sensiolabs.org/"
  url "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v1.11.6/php-cs-fixer.phar"
  sha256 "ef5ec083b77f2a741a00abd7da93e6646264328deb191af4b827f1a4ff26ea85"
  version "1.11.6"

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
