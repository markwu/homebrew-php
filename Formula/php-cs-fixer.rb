require "formula"

class PhpCsFixer < Formula
  desc "PHP Coding Standards Fixer"
  homepage "http://cs.sensiolabs.org/"
  url "http://get.sensiolabs.org/php-cs-fixer.phar"
  sha256 "245050d32d6e0f9e252e433bd681ec4cb84d75ae4325b209e94c7bc4639a03b1"
  version "1.1.2"

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
