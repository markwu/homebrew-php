require "formula"

class Phpcpd < Formula
  desc "Copy/Paste Detector (CPD) for PHP code"
  homepage "https://github.com/sebastianbergmann/phpcpd"
  head "https://phar.phpunit.de/phpcpd.phar"

  def install
    libexec.install "phpcpd.phar"
    (libexec/"phpcpd.phar").chmod 0755
    bin.install_symlink libexec/"phpcpd.phar" => "phpcpd"
  end

  def caveats; <<-EOS.undent
    PHPCPD is now installed!

    To verify your installation, please run
    $ phpcpd --version
    EOS
  end
end
