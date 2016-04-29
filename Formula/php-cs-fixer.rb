require "formula"

class PhpCsFixer < Formula
  desc "PHP Coding Standards Fixer"
  homepage "http://cs.sensiolabs.org/"
  head "http://get.sensiolabs.org/php-cs-fixer.phar"

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
