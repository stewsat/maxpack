;;; Copyright (c) Stewsat
;;; Author: Yassin Achengli Benmouais
;;; SPDX-License-Identifier: BSD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defpackage #:maxpack
  (:use #:cl)
  (:export
   #:mImport
   #:mInstall
   #:mList
   #:mUninstall
   #:mRemove
   #:mExists
   #:mUpdate
   #:mSearch
   #:mInfo
   #:mVersion
   #:mpHome
   #:Maxpack-Cli))

(in-package #:maxpack)

(defun Print-Line (Prompt-Format &rest Args)
  "
  Print formated string to stdout with a trailing newline.
  "
  (when (stringp Prompt-Format)
    (apply #'format t (concatenate 'string Prompt-Format "~%") Args)))

(defun Trim (String)
  "
  Trim whitespace from both ends of a string.
  "
  (string-trim '(#\Space #\Tab #\Newline #\Return) String))

(defun Split-String (String Separator)
  "
  Split a string by separator character.
  "
  (uiop:split-string String :separator Separator))

(defun Dirname (Path)
  "
  Get the last directory component name from a pathname.
  "
  (car (last (pathname-directory Path))))
