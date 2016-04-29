require "formula"

class Phploc < Formula
  desc "A tool for quickly measuring the size of a PHP project"
  homepage "https://github.com/sebastianbergmann/phploc"
  url "https://phar.phpunit.de/phploc-3.0.1.phar"
  sha256 "a712dec6b1044505a411d207813c6b11cc1c138c0ed467f65788b6f9441c9701"
  version "3.0.1"

  def install
    File.rename("phploc-3.0.1.phar", "phploc.phar")
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
