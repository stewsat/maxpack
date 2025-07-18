;; Maxpack core
;; ---
;; Copyright (C) BY-NC 2025 - Yassin Achengli <achengli@github.com>
;; This file is under GPLv3 license. You can see the terms in
;; https://www.gnu.org/licenses/gpl-3.0.html#license-text

(require :asdf)
(ql:quickload "cl-ppcre")

(defconstant *MAXPACK-DIR* (concatenate 'string (uiop:getenv "HOME") "/.maxpack"))
(defconstant *MAXPACK-PACKAGES-DIR* (concatenate 'string *MAXPACK-DIR* "/packages"))

;; BEGIN MACRO-STORE
;; ---
;; Functions that get to be used a lot are expressed in a reduced form with
;; the following macros:
(defmacro strcat (&rest strings)
  `(concatenate 'string ,@strings))

(defmacro get-ref (symbol ref)
  "Macro to represent the reference of an assoc list."
  `(cdr (assoc ,symbol ,ref)))

(defmacro set-ref (symbol value ref)
  "Macro to set a value for a reference inside assoc list."
  `(if (assoc ,symbol ,ref)
       (setf (cdr (assoc ,symbol ,ref)) ,value)
       (setq ,ref (append ,ref (list (cons ,symbol ,value))))))

;; Join is not a macro but extends the function to join multiple strings
;; separated by a unique string.
(defun join (&rest args)
  (let ((separator (car args)))
    (format nil (uiop:strcat "~{~A~^" separator "~}") args)))

;; END MACRO-STORE

;; BEGIN MAXPACK functions
;; ---
;; Converts package metainfo to assoc
(defun maxpack#--parse-package-list (package-list-file)
  "Split package.list file parsing it to assoc list with
  selected parameters defined as follows."
  (let ((package-lines (uiop:read-file-lines package-list-file))
	(parsed '()))
    (loop for line in package-lines do
      (let* ((splited-line (uiop:split-string line :separator "/"))
	     (-protocol (cl-ppcre:regex-replace ":" (car splited-line) ""))
	     (-host (caddr splited-line))
	     (-user (cadddr splited-line))
	     (-package (cl-ppcre:regex-replace ".git" (car (reverse splited-line)) "")))
	(setq parsed (append parsed (list (list 'protocol -protocol)
					  (list 'host -host)
					  (list 'user -user)
					  (list 'package -package))))))
    parsed))



;; Perform git clone call with github as default server.
(defun maxpack#--git-clone (url &key (server :github))
  (let ((
  
;; Plug packages to install
(defun maxpack#plug (pkg &key (version :latest) (host :github))
  (let ((pkg-split (uiop:split-string pkg :separator "/"))
        (pkg-owner (car pkg-split))
        (pkg-name (cdr pkg-split)))
  (if (equal version :latest)
    (when (not (probe-file (concat *MAXPACK-DIR* "/packages/" pkg-name "/latest")))
      (progn
        (ensure-directories-exist (concat *MAXPACK-DIR* "/packages" pkg-name "/latest"))
        (let ((url (if (equal host :github)
                     pkg (join "/" host pkg-owner pkg-name))))
        (maxpack#--git-clone url :server host)) 

(defmacro strcat (&rest strings)
  `(concatenate 'string ,@strings))

(defun maxpack#install ()
  (dolist (pkg (maxpack#--parse-package-list (concatenate 'string *MAXPACK-DIR* "/package.list")))
    (if (probe-file (strcat *MAXPACK-DIR* "/packages/" (get-ref 'package pkg)))
      (if (probe-file (strcat 
    
