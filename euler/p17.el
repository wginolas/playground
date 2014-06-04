; If the numbers 1 to 5 are written out in words: one, two, three, four, five, then there are 3 + 3 + 5 + 4 + 4 = 19 letters used in total.
;
; If all the numbers from 1 to 1000 (one thousand) inclusive were written out in words, how many letters would be used?
;
; NOTE: Do not count spaces or hyphens. For example, 342 (three hundred and forty-two) contains 23 letters and 115 (one hundred and fifteen) contains 20 letters. The use of "and" when writing out numbers is in compliance with British usage.

(defun p17-number-to-str (n)
  (cond
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
   ))

(p17-number-to-str 14)
(str "1" "234")
