require "formula"

class Phpcs < Formula
  desc "Check coding standards in PHP, JavaScript and CSS"
  homepage "https://github.com/squizlabs/PHP_CodeSniffer"
  head "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar"

  resource "phpcbf" do
    url "https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar"
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
