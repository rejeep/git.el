(require 'ert)
(require 'f)

(require 'git (f-expand "git" (f-parent (f-dirname (f-this-file)))))

(defvar git-sandbox-path
  (f-expand "git.el" (f-dirname (make-temp-file "git"))))

(defmacro with-sandbox (&rest body)
  `(let ((default-directory git-sandbox-path))
     (when (f-dir? git-sandbox-path)
       (f-delete git-sandbox-path :force))
     (f-mkdir git-sandbox-path)
     ,@body))
