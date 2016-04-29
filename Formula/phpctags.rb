require "formula"

class Phpctags < Formula
  desc "An enhanced ctags compatible index generator written in pure PHP"
  homepage "https://github.com/vim-php/phpctags"
  head "http://vim-php.com/phpctags/install/phpctags.phar"

  def install
    libexec.install "phpctags.phar"
    (libexec/"phpctags.phar").chmod 0755
    bin.install_symlink libexec/"phpctags.phar" => "phpctags"
  end

  def caveats; <<-EOS.undent
    phpctags is now installed!

    To verify your installation, please run
    $ phpctags --version
    EOS
  end
end
