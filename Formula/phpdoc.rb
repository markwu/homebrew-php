require "formula"

class Phpdoc < Formula
  desc "Documentation Generator for PHP"
  homepage "https://www.phpdoc.org/"
  url "https://github.com/phpDocumentor/phpDocumentor2/releases/download/v2.9.0/phpDocumentor.phar"
  sha256 "c7dadb6af3feefd4b000c19f96488d3c46c74187701d6577c1d89953cb479181"
  version "2.9.0"

  def install
    libexec.install "phpDocumentor.phar"
    (libexec/"phpDocumentor.phar").chmod 0755
    bin.install_symlink libexec/"phpDocumentor.phar" => "phpdoc"
  end

  def caveats; <<-EOS.undent
    phpDocumentor is now installed!

    To verify your installation, please run
    $ phpdoc --version
    EOS
  end
end
