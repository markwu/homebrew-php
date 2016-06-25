require "formula"

class Phpcs < Formula
  desc "Check coding standards in PHP, JavaScript and CSS"
  homepage "https://github.com/squizlabs/PHP_CodeSniffer"
  url "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/2.6.1/phpcs.phar"
  sha256 "cfa9d7e670682aafdaef4be7c8e1a3f01440f784a8e350a655114070339a6255"
  version "2.6.1"

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
