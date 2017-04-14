class Bzip2 < Formula
  desc "Freely available high-quality data compressor"
  homepage "http://www.bzip.org/"
  url "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
  sha256 "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "197655415959a8e856f5926ebbae88715b8aef68fa8612aaf0bfe7e1c96723bf" => :high_sierra
    sha256 "8911d7904862dc4930d024d0459390c510566241015bc06ec97f9e3fbb869101" => :sierra
    sha256 "a22f768ce625a56cc2f4b3c7f08f4b1ba30f79865b786dc4c57a97f672badff4" => :el_capitan
    sha256 "1468f967e8a35954509a8beb40bd29b60b730db158054aeddadc7586890737e8" => :yosemite
  end

  keg_only :provided_by_osx

  patch :DATA

  def install
    inreplace "Makefile", "$(PREFIX)/man", "$(PREFIX)/share/man"

    system "make", "install", "PREFIX=#{prefix}", "VERSION=#{version}"
  end

  test do
    testfilepath = testpath + "sample_in.txt"
    zipfilepath = testpath + "sample_in.txt.bz2"

    testfilepath.write "TEST CONTENT"

    system "#{bin}/bzip2", testfilepath
    system "#{bin}/bunzip2", zipfilepath

    assert_equal "TEST CONTENT", testfilepath.read
  end
end

__END__
diff --git 1/Makefile 2/Makefile
index 9754ddf286b1..1ef7d3f19e47 100644
--- 1/Makefile
+++ 2/Makefile-copy
@@ -35,9 +35,9 @@ OBJS= blocksort.o  \
       decompress.o \
       bzlib.o
 
-all: libbz2.a bzip2 bzip2recover test
+all: libbz2.a libbz2.dylib bzip2 bzip2recover test
 
-bzip2: libbz2.a bzip2.o
+bzip2: libbz2.a libbz2.dylib bzip2.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2
 
 bzip2recover: bzip2recover.o
@@ -52,15 +52,23 @@ libbz2.a: $(OBJS)
 		$(RANLIB) libbz2.a ; \
 	fi
 
+libbz2.dylib: $(OBJS)
+	rm -f libbz2.dylib
+	$(CC) -dynamiclib $(OBJS) -o libbz2.$(VERSION).dylib \
+		-install_name $(PREFIX)/lib/libbz2.$(VERSION).dylib \
+		-compatibility_version 1.0 -current_version $(VERSION)
+	ln -s libbz2.$(VERSION).dylib libbz2.1.0.dylib
+	ln -s libbz2.$(VERSION).dylib libbz2.dylib
+
 check: test
 test: bzip2
 	@cat words1
-	./bzip2 -1  < sample1.ref > sample1.rb2
-	./bzip2 -2  < sample2.ref > sample2.rb2
-	./bzip2 -3  < sample3.ref > sample3.rb2
-	./bzip2 -d  < sample1.bz2 > sample1.tst
-	./bzip2 -d  < sample2.bz2 > sample2.tst
-	./bzip2 -ds < sample3.bz2 > sample3.tst
+	DYLD_LIBRARY_PATH=. ./bzip2 -1  < sample1.ref > sample1.rb2
+	DYLD_LIBRARY_PATH=. ./bzip2 -2  < sample2.ref > sample2.rb2
+	DYLD_LIBRARY_PATH=. ./bzip2 -3  < sample3.ref > sample3.rb2
+	DYLD_LIBRARY_PATH=. ./bzip2 -d  < sample1.bz2 > sample1.tst
+	DYLD_LIBRARY_PATH=. ./bzip2 -d  < sample2.bz2 > sample2.tst
+	DYLD_LIBRARY_PATH=. ./bzip2 -ds < sample3.bz2 > sample3.tst
 	cmp sample1.bz2 sample1.rb2 
 	cmp sample2.bz2 sample2.rb2
 	cmp sample3.bz2 sample3.rb2
@@ -89,6 +97,9 @@ install: bzip2 bzip2recover
 	chmod a+r $(PREFIX)/include/bzlib.h
 	cp -f libbz2.a $(PREFIX)/lib
 	chmod a+r $(PREFIX)/lib/libbz2.a
+	cp -f libbz2.$(VERSION).dylib $(PREFIX)/lib
+	ln -s libbz2.$(VERSION).dylib $(PREFIX)/lib/libbz2.1.0.dylib
+	ln -s libbz2.$(VERSION).dylib $(PREFIX)/lib/libbz2.dylib
 	cp -f bzgrep $(PREFIX)/bin/bzgrep
 	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzegrep
 	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzfgrep
@@ -109,7 +120,7 @@ install: bzip2 bzip2recover
 	echo ".so man1/bzdiff.1" > $(PREFIX)/man/man1/bzcmp.1
 
 clean: 
-	rm -f *.o libbz2.a bzip2 bzip2recover \
+	rm -f *.o libbz2.a libbz2.*.dylib bzip2 bzip2recover \
 	sample1.rb2 sample2.rb2 sample3.rb2 \
 	sample1.tst sample2.tst sample3.tst
 
