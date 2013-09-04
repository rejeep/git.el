(require 'ert)
(require 'f)

(require 'git (f-expand "git" (f-parent (f-dirname (f-this-file)))))

(defvar git-sandbox-path
  (f-expand "git.el" (f-dirname (make-temp-file "git"))))

(defmacro with-sandbox (&rest body)
  `(let ((default-directory git-sandbox-path)
         (git-repo git-sandbox-path))
     (when (f-dir? git-sandbox-path)
       (f-delete git-sandbox-path :force))
     (f-mkdir git-sandbox-path)
     ,@body))

(defmacro with-git-repo (&rest body)
  `(with-sandbox
    (git-init ,git-sandbox-path)
    ,@body))

(defmacro with-initialized-git-repo (&rest body)
  `(with-git-repo
    (f-touch "README")
    (git-add "README")
    (git-commit "Initial commit." "README")
    ,@body))
