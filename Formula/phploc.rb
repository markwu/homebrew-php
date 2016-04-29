require "formula"

class Phploc < Formula
  desc "A tool for quickly measuring the size of a PHP project"
  homepage "https://github.com/sebastianbergmann/phploc"
  head "https://phar.phpunit.de/phploc.phar"

  def install
    libexec.install "phploc.phar"
    (libexec/"phploc.phar").chmod 0755
    bin.install_symlink libexec/"phploc.phar" => "phploc"
  end

  def caveats; <<-EOS.undent
    PHPLOC is now installed!

    To verify your installation, please run
    $ phploc --version
    EOS
  end
end
