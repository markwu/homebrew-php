require "formula"

class Php7cc < Formula
  desc "PHP 7 Compatibility Checker"
  homepage "https://github.com/sstalle/php7cc"
  url "https://github.com/sstalle/php7cc/releases/download/1.1.0/php7cc.phar"
  sha256 "af1845ee3622630c3a87fe7928c4249e0070beb6392a6a1faac04cae962aee42"
  version "1.1.0"

  def install
    libexec.install "php7cc.phar"
    (libexec/"php7cc.phar").chmod 0755
    bin.install_symlink libexec/"php7cc.phar" => "php7cc"
  end

  def caveats; <<-EOS.undent
    php7cc is now installed!

    To verify your installation, please run
    $ php7cc --version
    EOS
  end
end
