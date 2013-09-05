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

;; Todo: no-pager

(require 's)
(require 'dash)
(require 'f)

(defvar git-executable
  (executable-find "git")
  "Git executable.")

(defvar git-repo nil
  "Path to current working repo.")

(defconst git-stash-re "^\\(.+?\\): \\(?:WIP on\\|On\\) \\(.+\\): \\(.+\\)$"
  "Regular expression matching a stash.")

(defun git-run (&rest args)
  "Run git command.

ARGS are passed as argument to the `git-executable'. To enable an
option, use the `option' directive."
  (let ((default-directory (f-full git-repo)))
     (with-temp-buffer
       (apply
        'call-process
        (append
         (list git-executable nil (current-buffer) nil)
         (-flatten (-reject 'null args))))
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
  (-contains? (git-branches) branch))

(defun git-tag? (tag)
  "Return true if there's a tag called TAG."
  (-contains? (git-tags) tag))

(defun git-on-branch ()
  "Return currently active branch."
  (git-run "rev-parse" "--abbrev-ref" "HEAD"))

(defun git-on-branch? (branch)
  "Return true if BRANCH is currently active."
  (equal branch (git-on-branch)))

;; Todo: Multiple paths
(defun git-add (&optional path)
  "Add PATH or everything."
  (git-run "add" (or path ".")))

(defun git-branch (branch)
  "Create BRANCH."
  (if (git-branch? branch)
      (error "Branch already exists %s" branch)
    (git-run "branch" branch)))

(defun git-branches ()
  "List all available branches."
  (-map
   (lambda (line)
     (if (s-starts-with? "*" line)
         (substring line 2)
       line))
   (git--lines (git-run "branch"))))

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
  (git-run "init" (and bare "--bare")))

;; Todo: The solution used here is not bulletproof. For example if the
;; message contains a pipe, the :message will only include everything
;; before that pipe. Figure out a good solution for this.
(defun git-log (&optional branch)
  "Log history on BRANCH."
  (let ((logs (git--lines (git-run "log" "--format=%h|%an|%ae|%cn|%ce|%ad|%s"))))
    (-map
     (lambda (log)
       (let ((data (s-split "|" log)))
         (list
          :commit (nth 0 data)
          :author-name (nth 1 data)
          :author-email (nth 2 data)
          :comitter-name (nth 3 data)
          :comitter-email (nth 4 data)
          :date (nth 5 data)
          :message (nth 6 data))))
     logs)))

(defun git-config (option &optional value)
  "Set or get config OPTION. Set to VALUE if present."
  (s-presence (s-trim (git-run "config" option value))))

(defun git-pull (&optional repo ref)
  "..."
  )

(defun git-push (&optional repo ref)
  "..."
  )

(defun git-remote? (name)
  "Return true if remote with NAME exists, false otherwise."
  (-contains? (git-remotes) name))

(defun git-remotes ()
  "Return list of all remotes."
  (git--lines (git-run "remote")))

(defun git-remote-add (name url)
  "Add remote with NAME and URL."
  (git-run "remote" "add" name url))

(defun git-remote-remove (name)
  "Remove remote with NAME."
  (if (git-remote? name)
      (git-run "remote" "remove" name)
    (error "No such remote %s" name)))

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

(defun git-stash (&optional name)
  "Stash!"
  (git-run "stash" "save" "--" name))

(defun git-stashes ()
  "Return list of stashes."
  (let ((stashes (git--lines (git-run "stash" "list"))))
    (-map
     (lambda (stash)
       (let ((matches (s-match git-stash-re stash)))
         (list :name (nth 1 matches)
               :branch (nth 2 matches)
               :message (nth 3 matches))))
     stashes)))

(defun git-stash-pop (&optional message)
  "Apply and remove stash with MESSAGE (or first stash)."
  (git-run "stash" "pop" (git--stash-find message)))

(defun git-stash-apply (&optional message)
  "Apply and keep stash with MESSAGE (or first stash)."
  (git-run "stash" "apply" (git--stash-find message)))

(defun git-tag (tag)
  "Create TAG."
  (if (git-tag? tag)
      (error "Tag already exists %s" tag)
    (git-run "tag" tag)))

(defun git-tags ()
  "Return list of all tags."
  (git--lines (git-run "tag")))

(defun git-untracked-files ()
  "Return list of untracked files."
  (git--lines
   (git-run "ls-files" "--other" "--exclude-standard")))

(defun git-staged-files ()
  "Return list of staged files."
  (git--lines
   (git-run "diff" "--cached" "--name-only")))


;;;; Helpers

(defun git--lines (string)
  (-reject 's-blank? (-map 's-trim (s-lines string))))

(defun git--stash-find (message)
  (plist-get
   (-first
    (lambda (stash)
      (equal (plist-get stash :message) message))
    (git-stashes))
   :name))

(provide 'git)

;;; git.el ends here
