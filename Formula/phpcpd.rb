require "formula"

class Phpcpd < Formula
  desc "Copy/Paste Detector (CPD) for PHP code"
  homepage "https://github.com/sebastianbergmann/phpcpd"
  url "https://phar.phpunit.de/phpcpd-2.0.4.phar"
  sha256 "491eeac71f1421395648ff079b60fe4858217b70d66eaa07644351f2699c38fe"
  version "2.0.4"

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
