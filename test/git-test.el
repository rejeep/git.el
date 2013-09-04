(ert-deftest git-init-test/with-dir ()
  (with-sandbox
   (git-init git-sandbox-path)
   (should (git-repo? git-sandbox-path))))

(ert-deftest git-init-test/without-dir ()
  (with-sandbox
   (let ((git-repo git-sandbox-path))
     (git-init)
     (should (git-repo? git-sandbox-path)))))

(ert-deftest git-init-test/bare ()
  (with-sandbox
   (git-init git-sandbox-path :bare)
   (should (git-repo? git-sandbox-path))))

(ert-deftest git-untracked-test/no-files ()
  (with-sandbox
   (git-init git-sandbox-path)
   (should-not (git-untracked-files))))

(ert-deftest git-untracked-test/single-file ()
  (with-sandbox
   (git-init git-sandbox-path)
   (f-touch "foo")
   (should (equal (git-untracked-files) '("foo")))))

(ert-deftest git-untracked-test/multiple-files ()
  (with-sandbox
   (git-init git-sandbox-path)
   (f-touch "foo")
   (f-touch "bar")
   (should (equal (git-untracked-files) '("bar" "foo")))))

(ert-deftest git-untracked-test/file-in-directory ()
  (with-sandbox
   (git-init git-sandbox-path)
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (should (equal (git-untracked-files) '("foo/bar")))))

(ert-deftest git-untracked-test/with-staged-files ()
  (with-sandbox
   (git-init git-sandbox-path)
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (f-touch (f-join "foo" "baz"))
   (git-add (f-join "foo" "bar"))
   (should (equal (git-untracked-files) '("foo/baz")))))
