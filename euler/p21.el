; Let d(n) be defined as the sum of proper divisors of n (numbers less
; than n which divide evenly into n).  If d(a) = b and d(b) = a, where
; a ≠ b, then a and b are an amicable pair and each of a and b are
; called amicable numbers.
;
; For example, the proper divisors of 220 are
; 1, 2, 4, 5, 10, 11, 20, 22, 44, 55 and 110; therefore d(220) =
; 284. The proper divisors of 284 are 1, 2, 4, 71 and 142; so d(284) =
; 220.
;
; Evaluate the sum of all the amicable numbers under 10000.

(defun p21-divisor-vector-calc (len)
  (let ((result (make-vector (+ len 1) nil))
        (d 1)
        (i))
    (while (<= (* 2 d) len)
      (setq i (* 2 d))
      (while (<= i len)
        (aset result i (cons d (aref result i)))
        (setq i (+ d i)))
      (setq d (+ 1 d)))
    result))

(setq p21-divisor-vector (p21-divisor-vector-calc 30000))

(defun p21-proper-divisors-slow (n)
  (let ((result nil))
    (dotimes (count (/ n 2))
      (let ((i (+ 1 count)))
        (when (= 0 (% n i))
          (setq result (cons i result)))))
    (reverse result)))

(defun p21-proper-divisors (n)
  (aref p21-divisor-vector n))

(defun p21-d (n)
  (apply '+ (p21-proper-divisors n)))

(defun p21-is-amicable (n)
  (let ((d (p21-d n)))
    (and (/= d n) (= n (p21-d d)))))

(defun p21 ()
  (let ((result 0))
    (dotimes (i 9998)
      (let ((n (+ 1 i)))
        (when (p21-is-amicable n)
          (setq result (+ result n)))))
    result))

;(p21)
; 31626?

;(= 0 (% 10 5))
;(p21-is-amicable 220)
;(p21-d 284)
