(asdf:defsystem :maxpack
  :description "Maxima package manager."
  :author "Yassin Achengli"
  :license "MIT"
  :depends-on (:cl-json :drakma :uiop)
  :serial t
  :components ((:directory "maxpack")
