;; Maxpack testing suite
;; ---
;; Copyright (C) BY-NC 2025 - Yassin Achengli <achengli@github.com>
;; This file is under GPLv3 license. You can see the terms in
;; https://www.gnu.org/licenses/gpl-3.0.html#license-text

(let (testing-sources (list (pathname "../src/maxpack.lisp")))
  (loop for f in testing-sources do
        (load f)))

(defmacro maxpack#run-test (test-function :should result :with &rest params)
  (assert (test-function ,@params) result))
