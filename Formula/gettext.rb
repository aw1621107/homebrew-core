class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.19.8.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.xz"
  sha256 "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4"

  bottle do
    sha256 "99d2dbd4c9ebfe9bf2a64bd99f3a695a18635f0d9110eaff34bab8022abef6a8" => :high_sierra
    sha256 "8368522242c5fe33acd5c80b5f1321559da9efe20878da6e4b9507683a740c21" => :sierra
    sha256 "311475f36f3fd314ae0db4fb52e4ab769f62ded6c8c81678ad8295f41762e4ba" => :el_capitan
    sha256 "ca8fe572e7c8db00bb1bdfd66c379ba4a960927f4b829f47f9e2335c51dc7376" => :yosemite
    sha256 "e3091192716347fc54f6e8a8184d892feed5309672daa061a1407b071af80c05" => :mavericks
  end

  keg_only :shadowed_by_osx,
    "macOS provides the BSD gettext library & some software gets confused if both are in the library path"

  # https://savannah.gnu.org/bugs/index.php?46844
  if MacOS.version <= :mountain_lion
    depends_on "libxml2"
  else
    depends_on "libxml2" => :optional
  end

  depends_on "libiconv" => :optional
  depends_on "ncurses" => :optional
  depends_on :java => :optional
  depends_on "mono" => :optional
  depends_on "git" => :optional
  depends_on "gnu-tar" => :optional
  depends_on "gzip" => :optional
  depends_on "bzip2" => :optional
  depends_on "xz" => :optional
  depends_on "glib" => :optional
  depends_on "libcroco" => :optional
  depends_on "libunistring" => :optional
  depends_on "cvs" => :optional

  depends_on :tex => [:optional, :build]
  depends_on "emacs" => [:optional, :build]

  option "with-openmp", "Build using openmp"

  needs :openmp if build.with? "openmp"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-debug
      --prefix=#{prefix}
      --with-included-gettext
      --with-emacs
      --with-lispdir=#{elisp}
    ]
    if build.with? :java
      args << "--enable-java"
    else
      args << "--disable-java"
    end
    if build.with? "mono"
      args << "--enable-csharp=mono"
    else
      args << "--disable-csharp"
    end
    if build.with? "glib"
      args << "--with-libglib-2.0-prefix=#{Formula["glib"].opt_prefix}"
    else
      args << "--with-included-glib"
    end
    if build.with? "libcroco"
      args << "--with-libcroco-0.6-prefix=#{Formula["libcroco"].opt_prefix}"
    else
      args << "--with-included-libcroco"
    end
    if build.with? "libunistring"
      args << "--with-libunistring-prefix=#{Formula["libunistring"].opt_prefix}"
    else
      args << "--with-included-libunistring"
    end
    if build.with? "git"
      args << "--with-git"
    else
      args << "--without-git"
    end
    if build.with? "cvs"
      args << "--with-cvs"
    else
      args << "--without-cvs"
    end
    if build.with? "xz"
      args << "--with-xz"
    else
      args << "--without-xz"
    end

    if build.with? "libiconv"
      args << "with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}"
    end
    if build.with? "libxml2"
      args << "--with-libxml2-prefix=#{Formula["libxml2"].opt_prefix}"
    end
    if build.with? "ncurses"
      args << "--with-libncurses-prefix=#{Formula["ncurses"].opt_prefix}"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system bin/"gettext", "test"
  end
end
