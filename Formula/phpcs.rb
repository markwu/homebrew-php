require "formula"

class Phpcs < Formula
  desc "Check coding standards in PHP, JavaScript and CSS"
  homepage "https://github.com/squizlabs/PHP_CodeSniffer"
  url "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar"
  sha256 "81e8df3aa89f1920994fb818ccbac7ea40251e3dd0473effb41981d209d9b40a"
  version "2.6.0"

  resource "phpcbf" do
    url "https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar"
    sha256 "b230cc5804dcd17bf2bc52d5eda0cfa60423e3afd68641f8bebea0f698284ec6"
  end

  def install
    libexec.install "phpcs.phar"
    (libexec/"phpcs.phar").chmod 0755
    bin.install_symlink libexec/"phpcs.phar" => "phpcs"

    resource("phpcbf").stage do
      libexec.install "phpcbf.phar"
      (libexec/"phpcbf.phar").chmod 0755
      bin.install_symlink libexec/"phpcbf.phar" => "phpcbf"
    end
  end

  def caveats; <<-EOS.undent
    PHP_CodeSniffer is now installed!

    To verify your installation, please run
    $ phpcs --version
    EOS
  end
end
