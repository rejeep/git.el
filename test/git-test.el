;;;; git-init

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


;;;; git-untracked-files

(ert-deftest git-untracked-files-test/no-files ()
  (with-git-repo
   (should-not (git-untracked-files))))

(ert-deftest git-untracked-files-test/single-file ()
  (with-git-repo
   (f-touch "foo")
   (should (equal (git-untracked-files) '("foo")))))

(ert-deftest git-untracked-files-test/multiple-files ()
  (with-git-repo
   (f-touch "foo")
   (f-touch "bar")
   (should (equal (git-untracked-files) '("bar" "foo")))))

(ert-deftest git-untracked-files-test/file-in-directory ()
  (with-git-repo
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (should (equal (git-untracked-files) '("foo/bar")))))

(ert-deftest git-untracked-files-test/with-staged-files ()
  (with-git-repo
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (f-touch (f-join "foo" "baz"))
   (git-add (f-join "foo" "bar"))
   (should (equal (git-untracked-files) '("foo/baz")))))


;;;; git-staged-files

(ert-deftest git-staged-files-test/no-files ()
  (with-git-repo
   (should-not (git-staged-files))))

(ert-deftest git-staged-files-test/single-file ()
  (with-git-repo
   (f-touch "foo")
   (git-add "foo")
   (should (equal (git-staged-files) '("foo")))))

(ert-deftest git-staged-files-test/multiple-files ()
  (with-git-repo
   (f-touch "foo")
   (f-touch "bar")
   (git-add "foo")
   (git-add "bar")
   (should (equal (git-staged-files) '("bar" "foo")))))

(ert-deftest git-staged-files-test/file-in-directory ()
  (with-git-repo
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (git-add (f-join "foo" "bar"))
   (should (equal (git-staged-files) '("foo/bar")))))

(ert-deftest git-staged-files-test/with-untracked-files ()
  (with-git-repo
   (f-mkdir "foo")
   (f-touch (f-join "foo" "bar"))
   (f-touch (f-join "foo" "baz"))
   (git-add (f-join "foo" "bar"))
   (should (equal (git-staged-files) '("foo/bar")))))


;;;; git-run


;;;; git-repo?

(ert-deftest git-repo?-test/is-repo ()
  (with-git-repo
   (should (git-repo? git-sandbox-path))))

(ert-deftest git-repo?-test/is-repo-bare ()
  (with-sandbox
   (git-init git-sandbox-path :bare)
   (should (git-repo? git-sandbox-path))))

(ert-deftest git-repo?-test/is-not-repo ()
  (with-sandbox
   (should-not (git-repo? git-sandbox-path))))


;;;; git-branch?


;;;; git-tag?


;;;; git-on-branch


;;;; git-on-branch?


;;;; git-add


;;;; git-branch


;;;; git-checkout


;;;; git-clone


;;;; git-commit


;;;; git-diff


;;;; git-fetch


;;;; git-log


;;;; git-pull


;;;; git-push


;;;; git-remote


;;;; git-remote-add


;;;; git-remote-remove


;;;; git-reset


;;;; git-rm


;;;; git-show


;;;; git-stash


;;;; git-stash-pop


;;;; git-status


;;;; git-tag

