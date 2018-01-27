require "formula"

class Composer < Formula
  desc "Dependency Manager for PHP"
  homepage "http://getcomposer.org"
  url "https://getcomposer.org/download/1.6.2/composer.phar"
  sha256 "6ec386528e64186dfe4e3a68a4be57992f931459209fd3d45dde64f5efb25276"
  version "1.6.2"

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
