require 'formula'

class UniversalGlobal < Formula
  desc "Source code tag system"
  homepage "https://www.gnu.org/software/global/"
  url "https://ftp.gnu.org/gnu/global/global-6.6.4.tar.gz"
  mirror "https://ftpmirror.gnu.org/global/global-6.6.4.tar.gz"
  sha256 "987e8cb956c53f8ebe4453b778a8fde2037b982613aba7f3e8e74bcd05312594"

  head do
    url ":pserver:anonymous:@cvs.savannah.gnu.org:/sources/global", using: :cvs

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "flex" => :build
    ## gperf is provided by OSX Command Line Tools.
    depends_on "libtool" => :build
  end

  depends_on "universal-ctags/universal-ctags/universal-ctags"
  depends_on "python@3.9"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "libtool" => :build
  end

  skip_clean "lib/gtags"

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/e1/86/8059180e8217299079d8719c6e23d674aadaba0b1939e25e0cc15dcf075b/Pygments-2.7.4.tar.gz"
    sha256 "df49d09b498e83c1a73128295860250b0b7edd4c723a32e9bc0d295c7c2ec337"
  end

  def install
    system "sh", "reconf.sh" if build.head?

    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    pygments_args = %W[build install --prefix=#{libexec}]
    resource("Pygments").stage { system "python3", "setup.py", *pygments_args }

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-exuberant-ctags=#{Formula["universal-ctags/universal-ctags/universal-ctags"].opt_bin}/ctags
    ]

    # Fix detection of realpath() with Xcode >= 12
    ENV.append_to_cflags "-Wno-error=implicit-function-declaration"

    system "./configure", *args
    system "make", "install"

    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])

    etc.install "gtags.conf"

    # we copy these in already
    cd share/"gtags" do
      rm %w[README COPYING LICENSE INSTALL ChangeLog AUTHORS]
    end
  end
end
