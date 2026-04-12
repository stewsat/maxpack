;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2026 BY-NC Yassin Achengli Benmouais <yassin_achengli@hotmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'asdf)

(defpackage maxpack)

(load "./config.lisp")
(load "./utils.lisp")

(defconstant *maxpack-package-list-file* (concatenate 'string *maxpack-install-dir* "/maxpack-packages.list"))
(defconstant *maxpack-package-packages* (concatenate 'string *maxpack-install-dir* "/packages"))

(defun --maxpack-get-package-list-from-existing-dirs ()
  (let ((packages-list '()) (pkg-name "") (pkg-version ""))
  (dolist (dir (remove-if-not #'uiop:directory-exists-p (directory 
                                                           (concatenate 'string *maxpack-package-packages*
                                                                        "/*@*"))))
    (setq pkg-name (car (uiop:split-string (file-namestring dir) :separator "@"))
          pkg-version (cadr (uiop:split-string (file-namestring dir) :separator "@"))
          packages-list (append packages-list (cons (read-from-string pkg-name)
                                                    (pkg-version))))
  )
  packages-list))

(defun --maxpack-create-package-list-info ()
  (uiop:ensure-all-directories-exist (list *maxpack-package-list-file*
                                           *maxpack-package-packages*))
  (uiop:with-output-file (path *maxpack-package-list-file* :if-does-not-exist :create :if-exists :supersede)
                         (dolist pkg (--maxpack-get-package-list-from-existing-dirs)
                           (format path "~a~a~%" (car pkg) (cdr pkg)))))

(defun maxpack-list ()
  (let ((
         *package-list-info* *maxpack-package-list-file*))
    (unless (uiop:file-exists-p *package-list-info*)
      (--maxpack-create-package-list-info))

    (let ((*package-lines* (uiop:read-file-lines *package-list-info* :external-format :utf-8)))
      (dolist (line *package-lines*)
        (--utils-maxpack-print-line line)))
    ))

(defun maxpack-install (pkg-name &key (url nil) (release :latest))
  ;; TODO
  )

(defun maxpack-remove (pkg-name &key (release :the-biggest-one))
  ;; TODO
  )

(defun maxpack-search (&key (origin 'maxpack-default))
  ;; TODO
  )

(defun maxpack-info pkg-name (&key (release :latest))
  ;; TODO
  )

(defun maxpack-version ()
  ;; TODO

  )

(maxpack-list)
