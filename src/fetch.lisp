;; fetch.lisp
;; ---
;; Downloading and updating module using Git.

(in-package #:maxpack)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (use-package :uiop))

(defun git-available-p ()
  "Check if 'git' is available in system."
  (zerop (run-program "git" '("--version")
                      :output nil :error-output nil :ignore-error-status t)))

(defun git-clone (repo url &key (version nil))
  "Clone the repository `repo' in packages/ directory. If version
   is defined, will try to fetch to version tag."
  (let* ((target-path (merge-pathnames (format nil "~A/" repo) *package-directory*)))
    (if (probe-file target-path)
        (format t "Package ~A exists in the package/ directory. Skipping cloning.~%" repo)
        (progn
          (format t "Cloning ~A from ~A...~%" repo url)
          (run-program "git" `("clone" ,url ,(namestring target-path)))))
    (when version
      (format t "Checkout to selected version ~A...~%" version)
      (run-program "git" `("checkout" ,version)
                   :directory (namestring target-path)))
    target-path))

(defun git-update (repo)
  "Does pull from repository cloned yet."
  (let ((target-path (merge-pathnames (format nil "~A/" repo) *package-directory*)))
    (when (probe-file target-path)
      (format t "Updating ~A...~%" repo)
      (run-program "git" '("pull")
                   :directory (namestring target-path)))))

(defun delete-package (repo &optional version)
  "Remove the package locally installed, and if `version' exist. Will try to remove
   the package with `version' tagname."
  (let ((base-path (merge-pathnames (format nil "~A/" repo) *package-directory* )))
    (cond
      ((and version
            (probe-file (merge-pathnames (format nil "~A/" version) base-path)))
       (let ((version-path (merge-pathnames (format nil "~A/" version) base-path)))
         (format t "Dropping ~A version ~A...~%" repo version)
         (uiop:delete-directory-tree version-path :validate t)))
      ((probe-file base-path)
       (format t "Deleting all versions of ~A package...~%" repo)
       (uiop:delete-directory-tree base-path :validate t))
      (t (format t "Package ~A (~@[~A~]).~% wasn't found" repo version)))))


