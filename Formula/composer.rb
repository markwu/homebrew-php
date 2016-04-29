require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"

  def install
    libexec.install "composer.phar"
    (libexec/"composer.phar").chmod 0755
    bin.install_symlink libexec/"composer.phar" => "composer"
  end

  def caveats; <<-EOS.undent
    Composer is now installed!

    To verify your installation, please run
    $ composer --version
    EOS
  end
end
