;; Copyright (c) Stewsat
;; Author: Yassin Achengli Benmouais
;; SPDX-License-Identifier: BSD

(asdf:defsystem :maxpack
  :description "Maxima package manager."
  :author "Yassin Achengli"
  :license "MIT"
  :depends-on (:uiop)
  :serial t
  :components ((:file "maxpack/utils")
               (:file "maxpack/config")
               (:file "maxpack/maxpack")))
