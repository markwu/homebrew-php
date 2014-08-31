require "formula"

class Composer < Formula
  homepage "http://getcomposer.org"
  head "https://getcomposer.org/composer.phar"
  url "https://getcomposer.org/download/1.0.0-alpha8/composer.phar"
  sha1 "6eefa41101a2d1a424c3d231a1f202dfe6f09cf8"
  version "1.0.0-alpha8"

  def install
    libexec.install "composer.phar" => "composer"
    (libexec/"composer").chmod 755
    bin.install_symlink libexec/"composer"
  end

  def caveats; <<-EOS.undent
    composer is now installed!

    To verify your installation, please run
      `composer --version`
    EOS
  end
end
