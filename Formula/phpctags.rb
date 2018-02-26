require "formula"

class Phpctags < Formula
  desc "An enhanced ctags compatible index generator written in pure PHP"
  homepage "https://github.com/vim-php/phpctags"
  url "https://github.com/vim-php/phpctags/archive/0.6.0.tar.gz"
  sha256 "ed9ddbb56f672673274de7ef066071e703b5090d47c9ccc31442dd43b5775190"
  version "0.6.0"

  def install
    system "make"
    libexec.install "build/phpctags.phar"
    (libexec/"phpctags.phar").chmod 0755
    bin.install_symlink libexec/"phpctags.phar" => "phpctags"
  end

  def caveats; <<~EOS
    phpctags is now installed!

    To verify your installation, please run
    $ phpctags --version
    EOS
  end
end
