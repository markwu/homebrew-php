require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.0.3/composer.phar"
  sha256 "78c5c0e3f41dcd4d6ee532d9ae7e23afa33bdd409d8824dff026f3991d6ad70a"
  version "1.0.3"

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
