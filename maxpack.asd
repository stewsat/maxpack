(asdf:defsystem :maxpack
  :description "Maxima package manager."
  :author "Yassin Achengli"
  :license "MIT"
  :depends-on (:cl-json :drakma :uiop)
  :serial t
  :components ((:file "src/config")
               (:file "src/utils")
               (:file "src/hosts")
               (:file "src/fetch")
               (:file "src/versioning")
               (:file "src/manager")
               (:file "src/maxpack")))
