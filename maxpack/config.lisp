;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2026 BY-NC Yassin Achengli Benmouais <yassin_achengli@hotmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package #:maxpack)

(defparameter *Maxpack-Name* "maxpack")
(defparameter *Maxpack-Author* "Yassin Achengli <achengli@github.com>")
(defparameter *Maxpack-License* "BSD-3")
(defparameter *Maxpack-Homepage* "https://github.com/achengli/maxpack")
(defparameter *Maxpack-Version* "0.1.0")

(defparameter *Maxpack-Home-Dir*
  (or (uiop:getenv "MAXPACK_HOME")
      (concatenate 'string (uiop:getenv "HOME") "/.maxpack")))

(defparameter *Maxpack-Package-List-File*
  (concatenate 'string *Maxpack-Home-Dir* "/package.list"))

(defparameter *Maxpack-Registry-File*
  (concatenate 'string *Maxpack-Home-Dir* "/maxpack-registry.lisp"))

(defparameter *Maxpack-Host-List*
  '((maxpack-default "https://maxpack.org/packages/info.csv")))

(defparameter *Maxpack-Skip-Dirs*
  '("bin" "repo" "packages" "src" "test"))

(defun Read-Manifest (Pkg-Dir)
  "
  Parse manifest.toml from a package directory.
  Returns an alist of (key . value) pairs, or nil if not found.
  "
  (let ((Manifest-Path (merge-pathnames "manifest.toml" Pkg-Dir)))
    (when (uiop:file-exists-p Manifest-Path)
      (let ((Lines (uiop:read-file-lines Manifest-Path))
            (Result (list))
            (Current-Section nil))
        (dolist (Line Lines)
          (let ((Trimmed (Trim Line)))
            (unless (or (zerop (length Trimmed))
                        (char= (char Trimmed 0) #\#))
              (cond
                ((and (char= (char Trimmed 0) #\[)
                      (char= (char Trimmed (1- (length Trimmed))) #\]))
                 (setf Current-Section
                       (Trim (subseq Trimmed 1 (1- (length Trimmed))))))
                ((find #\= Trimmed)
                 (let* ((Eq-Pos (position #\= Trimmed))
                        (Key (Trim (subseq Trimmed 0 Eq-Pos)))
                        (Val (Trim (subseq Trimmed (1+ Eq-Pos))))
                        (Full-Key (if Current-Section
                                      (concatenate 'string Current-Section "." Key)
                                      Key)))
                   (push (cons Full-Key (Parse-Toml-Value Val)) Result)))))))
        (nreverse Result)))))

(defun Parse-Toml-Value (Raw)
  "
  Parse a TOML value string into a Lisp value.
  "
  (cond
    ((and (>= (length Raw) 2)
          (char= (char Raw 0) #\")
          (char= (char Raw (1- (length Raw))) #\"))
     (subseq Raw 1 (1- (length Raw))))
    ((and (>= (length Raw) 2)
          (char= (char Raw 0) #\[)
          (char= (char Raw (1- (length Raw))) #\]))
     (let ((Inner (Trim (subseq Raw 1 (1- (length Raw))))))
       (if (zerop (length Inner))
           '()
           (mapcar #'Trim (uiop:split-string Inner :separator #\,)))))
    ((string= Raw "true") t)
    ((string= Raw "false") nil)
    ((every (lambda (c) (or (digit-char-p c) (char= c #\.))) Raw)
     (let ((Num (read-from-string Raw)))
       (if (integerp Num) Num (coerce Num 'float))))
    (t Raw)))

(defun Manifest-Get (Manifest Key)
  "
  Get a value from a manifest alist by key.
  "
  (cdr (assoc Key Manifest :test #'string=)))

(defun Manifest-Dependencies (Manifest)
  "
  Get the list of dependencies from a manifest.
  "
  (let ((Raw (Manifest-Get Manifest "dependencies")))
    (if (listp Raw) Raw '())))
