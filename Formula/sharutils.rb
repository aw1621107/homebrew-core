class Sharutils < Formula
  desc "Utils to work with shell archives"
  homepage "https://www.gnu.org/software/sharutils/"
  url "ftp://ftp.gnu.org/gnu/sharutils/sharutils-4.15.tar.xz"
  sha256 "6a22459983d32ef4cbc201b4f43aa5505bc1bd02f2be4bbb81ef56bcb059f8a5"

  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libressl"

  keg_only "This formula installs uuencode and uudecode, which are provided by macOS"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-openssl"
    system "make", "install"
  end
end
