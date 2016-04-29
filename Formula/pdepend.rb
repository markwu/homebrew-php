require "formula"

class Pdepend < Formula
  desc "Static code analysis for PHP"
  homepage "https://pdepend.org/"
  url "http://static.pdepend.org/php/2.2.4/pdepend.phar"
  sha256 "8e50358ec15a37c542f07bc9521adcb63b5e3a2e7e3ed40b5ed7744172cc337f"
  version "2.2.4"

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
