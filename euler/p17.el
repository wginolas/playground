; If the numbers 1 to 5 are written out in words: one, two, three, four, five, then there are 3 + 3 + 5 + 4 + 4 = 19 letters used in total.
;
; If all the numbers from 1 to 1000 (one thousand) inclusive were written out in words, how many letters would be used?
;
; NOTE: Do not count spaces or hyphens. For example, 342 (three hundred and forty-two) contains 23 letters and 115 (one hundred and fifteen) contains 20 letters. The use of "and" when writing out numbers is in compliance with British usage.

(defun p17-number-to-str (n)
  (cond
   ((< n 1) nil)
   ((= n 1) "one")
   ((= n 2) "two")
   ((= n 3) "three")
   ((= n 4) "four")
   ((= n 5) "five")
   ((= n 6) "six")
   ((= n 7) "seven")
   ((= n 8) "eight")
   ((= n 9) "nine")
   ((= n 10) "ten")
   ((= n 11) "eleven")
   ((= n 12) "twelve")
   ((= n 13) "thirteen")
   ((= n 15) "fifteen")
   ((= n 18) "eighteen")
   ((< n 20) (concat (p17-number-to-str (mod n 10)) "teen"))
   ((= n 20) "twenty")
   ((= n 30) "thirty")
   ((= n 40) "forty")
   ((= n 50) "fifty")
   ((= n 80) "eighty")
   ((and (< n 100) (= 0 (mod n 10)))
    (concat (p17-number-to-str (/ n 10)) "ty"))
   ((and (< n 100) (/= 0 (mod n 10)))
    (let ((n10 (* (/ n 10) 10))
          (n1 (mod n 10)))
      (concat (p17-number-to-str n10) "-" (p17-number-to-str n1))))
   ((< n 1000)
    (let ((n100 (/ n 100))
          (n10 (mod n 100)))
      (concat
       (p17-number-to-str n100)
       " hundred"
       (if (= 0 n10)
           ""
         (concat " and " (p17-number-to-str n10))))))
   ((< n 1000000)
    (let ((n1000 (/ n 1000))
          (n100 (mod n 1000)))
      (concat
       (p17-number-to-str n1000)
       " thousand"
       (if (= 0 n100)
           ""
         (concat " " (p17-number-to-str n100))))))
   ))

(with-current-buffer (get-buffer-create "numbers")
  (erase-buffer)
  (dotimes (i 1000)
    (let ((n (+ i 1)))
      (insert (p17-number-to-str n))
      (insert "\n")))
  (perform-replace " " "" nil nil nil))

; 21124?

(p17-number-to-str 123456)
(str "1" "ninety")
(/ 123 10)
