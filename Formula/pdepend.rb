require "formula"

class Pdepend < Formula
  desc "Static code analysis for PHP"
  homepage "https://pdepend.org/"
  head "http://static.pdepend.org/php/latest/pdepend.phar"

  def install
    libexec.install "pdepend.phar"
    (libexec/"pdepend.phar").chmod 0755
    bin.install_symlink libexec/"pdepend.phar" => "pdepend"
  end

  def caveats; <<-EOS.undent
    PDepend is now installed!

    To verify your installation, please run
    $ pdepend --version
    EOS
  end
end
