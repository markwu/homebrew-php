require "formula"

class Phpcs < Formula
  desc "Check coding standards in PHP, JavaScript and CSS"
  homepage "https://github.com/squizlabs/PHP_CodeSniffer"
  url "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/2.6.2/phpcs.phar"
  sha256 "8ca80f20f5cf23632d4d9f9671f87a9a9dc098966d7c7eeeafa1b59ac156a039"
  version "2.6.2"

  resource "phpcbf" do
    url "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/2.6.2/phpcbf.phar"
    sha256 "8149a0d23ff82c656018426e0e70374ffe4fdfbaf62228b3a4272a7ceb7e0774"
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
