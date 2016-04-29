require "formula"

class Psysh < Formula
  desc "A REPL for PHP"
  homepage " http://psysh.org"
  head "http://psysh.org/psysh"

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
