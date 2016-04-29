require "formula"

class Phpmd < Formula
  desc "PHP Mess Dector"
  homepage "http://phpmd.org"
  head "http://static.phpmd.org/php/latest/phpmd.phar"

  def install
    libexec.install "phpmd.phar"
    (libexec/"phpmd.phar").chmod 0755
    bin.install_symlink libexec/"phpmd.phar" => "phpmd"
  end

  def caveats; <<-EOS.undent
    PHPMD is now installed!

    To verify your installation, please run
    $ phpmd --version
    EOS
  end
end
