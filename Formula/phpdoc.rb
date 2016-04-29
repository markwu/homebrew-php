require "formula"

class Phpdoc < Formula
  desc "Documentation Generator for PHP"
  homepage "https://www.phpdoc.org/"
  url "https://github.com/phpDocumentor/phpDocumentor2/releases/download/v2.8.5/phpDocumentor.phar"
  sha256 "7613a3d6ffc182595b7423bc2373cd215cac269135f4b0f973e5c1b617b565b7"
  version "2.8.5"

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
