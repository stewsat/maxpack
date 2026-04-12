;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2026 BY-NC Yassin Achengli Benmouais <yassin_achengli@hotmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'asdf)

(load "./utils.lisp")

(dolist (param (--utils-maxpack-get-metainfo))
  (defconstant 
    (read-from-string (concatenate 'string "*" (car param) "*"))
    (cdr param)))

(defconstant *maxpack-install-dir* (concatenate 'string (uiop:getenv "HOME") "/.maxpack"))

(defparameter *maxpack-host-list* '((maxpack-default "https://maxpack.org/packages/info.csv")))
