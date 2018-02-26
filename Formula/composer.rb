require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.6.3/composer.phar"
  sha256 "52cb7bbbaee720471e3b34c8ae6db53a38f0b759c06078a80080db739e4dcab6"
  version "1.6.3"

  def install
    libexec.install "composer.phar"
    (libexec/"composer.phar").chmod 0755
    bin.install_symlink libexec/"composer.phar" => "composer"
  end

  def caveats; <<~EOS
    Composer is now installed!

    To verify your installation, please run
    $ composer --version
    EOS
  end
end
