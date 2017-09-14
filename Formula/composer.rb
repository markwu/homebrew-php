require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.5.2/composer.phar"
  sha256 "c0a5519c768ef854913206d45bd360efc2eb4a3e6eb1e1c7d0a4b5e0d3bbb31f"
  version "1.5.2"

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
