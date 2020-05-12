(require 'buttercup)
(require 'sadl-mode)

(describe
 "sadl-mode"
 (it "works"
     (expect
      (with-temp-buffer
        (insert-file-contents "test/algebra.sadl")
        (sadl-mode)
        t)
      :to-be
      t))
 (it "finds the definition of Function"
     (expect
      (with-temp-buffer
        (insert-file-contents "test/algebra.sadl")
        (sadl-mode)
        (sadl--find-identifier "Function"))
      :not :to-be
      nil))
 )
