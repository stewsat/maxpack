;; Maxpack core
;; ---
;; Copyright (C) BY-NC 2025 - Yassin Achengli <achengli@github.com>
;; This file is under GPLv3 license. You can see the terms in
;; https://www.gnu.org/licenses/gpl-3.0.html#license-text

(require :asdf)
(ql:quickload "cl-ppcre")

(defparameter *pkg-list* 
  "`pkg-list' is a package container having the information of pluged packages
  using the function `maxpack#plug'."
  '())

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
;; TODO test function
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
;; TODO test function
(defun maxpack#--git-clone (url &key (server :github) (version :latest))
  (let* ((host (if (equal server :github) "https://github.com/" url))
        (pkg (if (equal server :github) (concat host url) url))
        (pkg-split (uiop:split-string url :separator "/"))
        (pkg-name (car (reverse pkg-split)))
        (pkg-owner (car (cdr (reverse pkg-split))))
        (destiny (join "/" *MAXPACK-DIR* pkg-name
                       (if (stringp version)
                         version
                         "latest"))))
    (uiop:run-program (concat "git clone " pkg " " destiny 
                              (if (equal version :latest) "" (concat " --branch " version))))))
  
;; Install package
;; TODO test function
(defun maxpack#install (pkg &key (version :latest) (host :github))
  (let ((pkg-split (uiop:split-string pkg :separator "/"))
        (pkg-owner (car pkg-split))
        (pkg-name (cdr pkg-split)))
    (if (equal version :latest)
      (when (not (probe-file (concat *MAXPACK-PACKAGES-DIR*  pkg-name "/latest")))
        (progn
          (ensure-directories-exist (concat *MAXPACK-PACKAGES-DIR* pkg-name "/latest"))
          (let ((url (if (equal host :github)
                       pkg (join "/" pkg-owner pkg-name))))
            (maxpack#--git-clone url :server host :version version))))
      (when (not (probe-file (concat *MAXPACK-PACKAGES-DIR* pkg-name version)))
        (progn
          (ensure-directories-exist (concat *MAXPACK-PACKAGES-DIR* pkg-name "/" version))
          (let ((url (if (equal host :github)
                       pkg (join "/" pkg-owner pkg-name))))
            (maxpack#--git-clone url :server host :version version)))))))

;; Plug a package
;; TODO test function
(defun maxpack#plug (pkg &key (version :latest) (host :github))
  (let* ((pkg-split (uiop:split-string pkg :separator "/"))
        (pkg-name (car (reverse pkg-split)))
        (pkg-owner (car (cdr (reverse pkg-split))))
        (pkg-assoc (list
                     (cons 'name pkg-name)
                     (cons 'owner pkg-owner)
                     (cons 'version version)
                     (cons 'host host))))
    (setq *pkg-list* (append *pkg-list* (list pkg-assoc)))))

;; Uninstall package 
(defun maxpack#remove (pkg &key (version :latest))
  (let* ((pkg-split (uiop:split-string pkg :separator "/"))
         (pkg-name (car (reverse pkg-split)))
         (pkg-owner (car (cdr (reverse pkg-split)))))
  (when (probe-file (join "/" *MAXPACK-PACKAGES-DIR* pkg-owner pkg-name))
    (uiop:delete-directory-tree (pathname (join "/" *MAXPACK-PACKAGES-DIR* pkg-owner pkg-name))
                                :validate nil))))

;; Get installed packages 
;; TODO : ensure functionality
(defun maxpack#ensure-installed () ;; --> Give an assoc list with installed packages.
  (let* ((pkg-dir-list (uiop:split-string 
                         (uiop:run-program (concat "ls " *MAXPACK-PACKAGES-DIR*)) :separator #(#\NewLine)))
         (pkg-dirs (mapcar (lambda (x) (car (reverse (pathname-directory x)))) pkg-dir-list)))
    (loop for dir in pkg-dirs do
          (let* ((pkg-subdir (uiop:split-string 
                               (uiop:run-program (concat "ls " *MAXPACK-PACKAGES-DIR* "/" dir)) :separator #(#\NewLine)))
                 (pkg-versions 
                   (mapcar (lambda (x) (list (cons 'name dir) (cons 'version (car (reverse (pathname-directory x)))))))))
            pkg-versions))))
            
