class Lzlib < Formula
  desc "Data compression library"
  homepage "http://www.nongnu.org/lzip/lzlib.html"
  url "https://download.savannah.gnu.org/releases/lzip/lzlib/lzlib-1.9.tar.gz"
  sha256 "2472f8d93830d0952b0c75f67e372d38c8f7c174dde2252369d5b20c87d3ba8e"

  bottle do
    cellar :any_skip_relocation
    sha256 "5a04bccace677f7d391564ce58624d3e2f3b5bc67964be861f952208037d0bec" => :high_sierra
    sha256 "730b7d59b3c8c3f8ca12053b2be57c36effa89f036a0a5c78395455fc3619477" => :sierra
    sha256 "116cf311291d7aaf0c13c5ac9e456a40261d036f75d21c6026e0b1c623bca2f4" => :el_capitan
    sha256 "f7be3aeb9e6142bbf3b35ff6212c81615a2ac02f0a65ad77216bcd15051bf147" => :yosemite
  end

  patch :DATA

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared",
                          "CC=#{ENV.cc}",
                          "CFLAGS=#{ENV.cflags}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdint.h>
      #include "lzlib.h"
      int main (void) {
        printf ("%s", LZ_version());
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-llz",
                   "-o", "test"
    assert_equal version.to_s, shell_output("./test")
  end
end

__END__
diff --git 1/Makefile.in 2/Makefile.in
index 02a1870c6725..45b52a5dd38a 100644
--- 1/Makefile.in
+++ 2/Makefile.in
@@ -23,14 +23,17 @@ all : $(progname_static) $(progname_shared)
 lib$(libname).a : lzlib.o
 	$(AR) -rcs $@ $<
 
-lib$(libname).so.$(pkgversion) : lzlib_sh.o
-	$(CC) $(LDFLAGS) $(CFLAGS) -fpic -fPIC -shared -Wl,--soname=lib$(libname).so.$(soversion) -o $@ $<
+lib$(libname).$(pkgversion).dylib : lzlib_sh.o
+	$(CC) $(LDFLAGS) $(CFLAGS) -fpic -fPIC -dynamiclib \
+		-install_name $(prefix)/lib/lib$(libname).$(pkgversion).dylib \
+		-compatibility_version 1.0 -current_version $(pkgversion) \
+		-o $@ $<
 
 $(progname) : $(objs) lib$(libname).a
 	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $(objs) lib$(libname).a
 
-$(progname)_shared : $(objs) lib$(libname).so.$(pkgversion)
-	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $(objs) lib$(libname).so.$(pkgversion)
+$(progname)_shared : $(objs) lib$(libname).$(pkgversion).dylib
+	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $(objs) lib$(libname).$(pkgversion).dylib
 
 bbexample : bbexample.o lib$(libname).a
 	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ bbexample.o lib$(libname).a
@@ -90,15 +93,15 @@ install-bin : all
 	  $(INSTALL_DATA) ./lib$(libname).a "$(DESTDIR)$(libdir)/lib$(libname).a" ; \
 	fi
 	if [ -n "$(progname_shared)" ] ; then \
-	  $(INSTALL_PROGRAM) ./lib$(libname).so.$(pkgversion) "$(DESTDIR)$(libdir)/lib$(libname).so.$(pkgversion)" ; \
-	  if [ -e "$(DESTDIR)$(libdir)/lib$(libname).so.$(soversion)" ] ; then \
+	  $(INSTALL_PROGRAM) ./lib$(libname).$(pkgversion).dylib "$(DESTDIR)$(libdir)/lib$(libname).$(pkgversion).dylib" ; \
+	  if [ -e "$(DESTDIR)$(libdir)/lib$(libname).$(soversion).dylib" ] ; then \
 	    run_ldconfig=no ; \
 	  else run_ldconfig=yes ; \
 	  fi ; \
-	  rm -f "$(DESTDIR)$(libdir)/lib$(libname).so" ; \
-	  rm -f "$(DESTDIR)$(libdir)/lib$(libname).so.$(soversion)" ; \
-	  cd "$(DESTDIR)$(libdir)" && ln -s lib$(libname).so.$(pkgversion) lib$(libname).so ; \
-	  cd "$(DESTDIR)$(libdir)" && ln -s lib$(libname).so.$(pkgversion) lib$(libname).so.$(soversion) ; \
+	  rm -f "$(DESTDIR)$(libdir)/lib$(libname).dylib" ; \
+	  rm -f "$(DESTDIR)$(libdir)/lib$(libname).$(soversion).dylib" ; \
+	  cd "$(DESTDIR)$(libdir)" && ln -s lib$(libname).$(pkgversion).dylib lib$(libname).dylib ; \
+	  cd "$(DESTDIR)$(libdir)" && ln -s lib$(libname).$(pkgversion).dylib lib$(libname).$(soversion).dylib ; \
 	  if [ "${disable_ldconfig}" != yes ] && [ $${run_ldconfig} = yes ] && \
 	     [ -x "$(LDCONFIG)" ] ; then "$(LDCONFIG)" -n "$(DESTDIR)$(libdir)" || true ; fi ; \
 	fi
@@ -137,9 +140,9 @@ uninstall-bin :
 	-rm -f "$(DESTDIR)$(bindir)/$(progname)"
 	-rm -f "$(DESTDIR)$(includedir)/$(libname)lib.h"
 	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).a"
-	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).so"
-	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).so.$(soversion)"
-	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).so.$(pkgversion)"
+	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).dylib"
+	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).$(soversion).dylib"
+	-rm -f "$(DESTDIR)$(libdir)/lib$(libname).$(pkgversion).dylib"
 
 uninstall-info :
 	-if $(CAN_RUN_INSTALLINFO) ; then \
@@ -176,7 +179,7 @@ dist : doc
 
 clean :
 	-rm -f $(progname) $(objs)
-	-rm -f $(progname)_shared lzlib_sh.o *.so.$(pkgversion)
+	-rm -f $(progname)_shared lzlib_sh.o *.$(pkgversion).dylib
 	-rm -f bbexample bbexample.o lzcheck lzcheck.o lzlib.o *.a
 
 distclean : clean
