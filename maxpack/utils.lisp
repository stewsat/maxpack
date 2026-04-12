;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2026 BY-NC Yassin Achengli Benmouais <yassin_achengli@hotmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun --utils-maxpack-print-line (prompt-format  &rest args &key (stdout t))
  "
  @brief    Print formated string in a single line.
  @key      `:stdout` outgoing way to print the content. If t is passed, the output
            is going to be stdout, else it will be a returned string if it is nill
            and otherwise, the stream passed as argument will be the outgoing gate.
  @rest     format parameters.
  @return   string in case of nil `:stdout` and t in the rest of cases except failures
            that will return nil value.
  "
  (when (stringp prompt-format)
    (apply #'format stdout (concatenate 'string prompt-format "~%") args)))

(defun --utils-maxpack-get-metainfo ()
  "
  @brief    Obtain information of maxpack package.
  @key      
