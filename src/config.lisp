;; config.lisp
;; --
;; Configuration of maxpack

(in-package #:maxpack)

(defparameter *package-directory*
  (merge-pathnames "packages/" (user-homedir-pathname)))

(defparameter *cache-directory*
  (merge-pathnames ".maxpack/cache/" (user-homedir-pathname)))

(defparameter *default-hosts*
  '("https://github.com/achengli/maxpack/raw/packages.json"))

(defparameter *maxpack-name* "maxpack")

(defparameter *maxpack-version* "0.1.0")

(defun ensure-directories-exist ()
  "Will create necessary directories if doesn't exist."
  (dolist (dir (list *package-directory* *cache-directory*))
    (unless (probe-file dir)
      (ensure-directories-exist dir))))

(ensure-directories-exist)
