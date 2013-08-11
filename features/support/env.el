(require 'f)

(defvar git-support-path
  (f-dirname load-file-name))

(defvar git-features-path
  (f-parent git-support-path))

(defvar git-root-path
  (f-parent git-features-path))

(add-to-list 'load-path git-root-path)

(require 'git)
(require 'espuds)
(require 'ert)
