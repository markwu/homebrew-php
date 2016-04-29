require "formula"

class Psysh < Formula
  desc "A REPL for PHP"
  homepage " http://psysh.org"
  url "http://psysh.org/psysh"
  sha256 "9a7ab733eecded5423937e104b41a6d4753e73b6201fe4f411981b2ff0b352ca"
  version "0.72"

  def install
    libexec.install "psysh"
    (libexec/"psysh").chmod 0755
    bin.install_symlink libexec/"psysh" => "psysh"
  end

  def caveats; <<-EOS.undent
    PsySH is now installed!

    To verify your installation, please run
    $ psysh --version
    EOS
  end
end
