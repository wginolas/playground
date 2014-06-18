

;;; Using names.txt (right click and 'Save Link/Target As...'), a 46K text
;;; file containing over five-thousand first names, begin by sorting it
;;; into alphabetical order. Then working out the alphabetical value for
;;; each name, multiply this value by its alphabetical position in the
;;; list to obtain a name score.
;;;
;;; For example, when the list is sorted into alphabetical order, COLIN,
;;; which is worth 3 + 15 + 12 + 9 + 14 = 53, is the 938th name in the
;;; list. So, COLIN would obtain a score of 938 × 53 = 49714.
;;;
;;; What is the total of all the name scores in the file?

(defun p22-word-value (w)
  (let ((result 0))
    (dotimes (i (length w))
      (setq result (+ result 1 (- (aref w i) ?A))))
    result))

(ert-deftest p22-word-value-test ()
  (should (= (p22-word-value "COLIN") 53))
  (should (= (p22-word-value "") 0))
  (should (= (p22-word-value "A") 2)))

(p22-word-value "COLIN")

(- (aref  "C" 0) ?A)
