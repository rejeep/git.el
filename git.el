;;; git.el --- Git API

;; Copyright (C) 2013 Johan Andersson

;; Author: Johan Andersson <johan.rejeep@gmail.com>
;; Maintainer: Johan Andersson <johan.rejeep@gmail.com>
;; Version: 0.0.1
;; Keywords: git
;; URL: http://github.com/rejeep/git.el
;; Package-Requires: ((s "1.7.0") (dash "2.2.0") (f "0.10.0"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(require 's)
(require 'dash)
(require 'f)

(defvar git-executable
  (executable-find "git")
  "Git executable.")

(defvar git-repo nil
  "Path to current working repo.")

(defmacro git-run (&rest args)
  "Run git command.

ARGS are passed as argument to the `git-executable'. To enable an
option, use the `option' directive."
  `(let ((default-directory (f-full git-repo)))
     (with-temp-buffer
       (apply
        'call-process
        (append
         (list git-executable nil (current-buffer) nil)
         (-flatten
          (-reject
           'null
           (-map
            (lambda (arg)
              (pcase arg
                (`(option ,name)
                 (when (and (boundp name) (eval name))
                   (concat "--" (symbol-name name))))
                (_ (eval arg))))
            ',args)))))
       (buffer-string))))

(defun git-repo? (directory)
  "Return true if there is a git repo in DIRECTORY, false otherwise."
  (or
   (f-dir? (f-expand ".git" directory))
   (and
    (f-dir? (f-expand "info" directory))
    (f-dir? (f-expand "objects" directory))
    (f-dir? (f-expand "refs" directory))
    (f-file? (f-expand "HEAD" directory)))))

(defun git-branch? (branch)
  "Return true if there's a branch called BRANCH."
  (-contains? (git-branch) branch))

(defun git-tag? (tag)
  "Return true if there's a tag called TAG."
  (-contains? (git-tag) tag))

(defun git-on-branch ()
  "Return currently active branch."
  (git-run "rev-parse" (option abbrev-ref) "HEAD"))

(defun git-on-branch? (branch)
  "Return true if BRANCH is currently active."
  (equal branch (git-on-branch)))

(defun git-add (&optional path)
  "Add PATH or everything."
  (git-run "add" (or path ".")))

(defun git-branch (&optional branch)
  "Create BRANCH or list all available branches."
  (if branch
      (if (git-branch? branch)
          (error "Branch already exists %s" branch)
        (git-run "branch" branch))
    (-map
     (lambda (line)
       (if (s-starts-with? "*" line)
           (substring line 2)
         line))
     (-reject 's-blank? (-map 's-trim (s-lines (git-run "branch")))))))

(defun git-checkout (branch)
  "Checkout BRANCH."
  (if (git-branch? branch)
      (unless (git-on-branch? branch)
        (git-run "checkout" branch))
    (error "No such branch %s" branch)))

(defun git-clone (url &optional dir)
  "Clone URL to DIR (if present)."
  (git-run "clone" url dir))

;; Todo: if expression contains option, must recurse down...
(defun git-commit (message &rest files)
  "Commit FILES (or added files) with MESSAGE."
  (let ((all (not files)))
    (git-run "commit" (option message) message (or files (option all)))))

;; Todo: not working
(defun git-diff (&optional blob-a blob-b path)
  "Diff PATH between BLOB-A and BLOB-B."
  (git-run "diff" (or blob-a (git-on-branch)) (or blob-b "master") path))

(defun git-fetch (&optional repo ref)
  "..."
  )

(defun git-init (&optional dir bare)
  "Create new Git repo at DIR (or `git-repo').

If BARE is true, create a bare repo."
  (let ((git-repo (or git-repo dir)))
    (git-run "init" (option bare))))

(defun git-log (&optional branch)
  "Log history on BRANCH."
  (git-run "log" branch))

(defun git-pull (&optional repo ref)
  "..."
  )

(defun git-push (&optional repo ref)
  "..."
  )

(defun git-remote ()
  "..."
  )

(defun git-remote-add (name url)
  "..."
  )

(defun git-remote-remove (name)
  "..."
  )

;; Todo: What about soft?
(defun git-reset (commit &optional hard)
  "..."
  )

(defun git-rm (path)
  "..."
  )

(defun git-show (&optional commit)
  "Show COMMIT."
  (git-run "show" commit))

(defun git-stash ()
  "Stash!"
  (git-run "stash"))

;; Todo: Option for keeping stash.
(defun git-stash-pop ()
  "Apply stash on top of stack and remove stash."
  (git-run "stash" "pop"))

(defun git-status ()
  "Show status information."
  (git-run "status"))

(defun git-tag (&optional tag)
  "Create TAG or list all available tags."
  (if tag
      (if (git-tag? tag)
          (error "Tag already exists %s" tag)
        (git-run "tag" tag))
    (git--lines (git-run "tag"))))

(defun git-untracked-files ()
  "Return list of untracked files."
  (git--lines
   (git-run "ls-files" "--other" "--exclude-standard")))


;;;; Helpers

(defun git--lines (string)
  (-reject 's-blank? (-map 's-trim (s-lines string))))

(provide 'git)

;;; git.el ends here
