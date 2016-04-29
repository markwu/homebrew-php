require "formula"

class Phpdocumentor < Formula
  desc "phpDocumentor analyzes your code to create great documentation"
  homepage "https://www.phpdoc.org/"
  head "http://phpdoc.org/phpDocumentor.phar"

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
