;; hosts.lisp
;; ---
;; host module loads the available package list from remotes.

(in-package #:maxpack)

(defvar *host-cache* nil
  "Package cache loaded from remotes.")

(defun fetch-host-json (url)
  "Downloads and parses the JSON package list from `url'."
  (handler-case
    (let ((response (drakma:http-request url)))
      (cl-json:decode-json-from-string (babel:octets-to-string response :encoding :utf-8)))
    (error (e)
           (format *error-output* "Error obtaining package list from ~A: ~A~%" url e)
           nil)))

(defun refresh-package-index ()
  "Loads package list from all available hosts and updates local cache."
  (setf *host-cache* nil)
  (dolist (url *default-hosts*)
    (let ((packages (fetch-host-json url)))
      (when packages
        (setf *host-cache* (append packages *host-cache*))))))

(defun list-available-packages ()
  "Returns a list of available packages from host."
  (unless *host-cache*
    (refresh-package-index))
  (loop for pkg in *host-cache*
        collect (list :name (getf pkg :name)
                      :repo (getf pkg :repo)
                      :versions (getf pkg :versions))))

(defun print-available-packages ()
  "List all available packages."
  (format t "~%Paquetes disponibles:~%")
  (dolist (pkg (list-available-packages))
    (format t "- ~A (versions: ~{~A~^, ~})~%"
            (getf pkg :name)
            (getf pkg :versions))))
