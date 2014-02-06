;A number chain is created by continuously adding the square of the digits in a number to form a new number until it has been seen before.
;
;For example,
;
;44 → 32 → 13 → 10 → 1 → 1
;85 → 89 → 145 → 42 → 20 → 4 → 16 → 37 → 58 → 89
;
;Therefore any chain that arrives at 1 or 89 will become stuck in an endless loop. What is most amazing is that EVERY starting number will eventually arrive at 1 or 89.
;
;How many starting numbers below ten million will arrive at 89?


(defn digits [i]
  (loop [n i
         r '()]
    (if (zero? n)
      r
      (recur (quot n 10) (conj r (mod n 10))))))

(defn square [i]
  (* i i))

(defn nextNum [i]
  (reduce + (map square (digits i))))

(defn end [i cache]
  (let [fromCache (cache i)]
    (if (nil? fromCache)
      (let [[r cache] (end (nextNum i) cache)]
        [r (assoc cache i r)])
      [fromCache cache])))

(defn p92 [max]
  (loop [i 1
         cnt 0
         cache {1 1 89 89}]
    (if (> i max)
      cnt
      (let [[r cache] (end i cache)]
        (recur
         (inc i)
         (if (== r 89) (inc cnt) cnt)
         cache)))))

(p92 9999999)

(end 3 {1 1 89 89})

(defn end2 [i cache]
  (loop [i i
         cache cache]
    (let [fromCache (cache i)
          next (nextNum i)
          cache (assoc cache i next)]
      (cond
       (or (== i 1) (== i 89)) [i cache]
       (nil? fromCache) [fromCache cache]
       :else (recur (nextNum i) cache)))))



(end 85 {})

(nextNum 44)

(doc map)
(doc reduce)

(digits 0)

(% 5 2)
(doc %)
(doc recur)
(doc loop)
(doc dec)

(defn test [i]
  (loop [cnt i]
    (println cnt)
    (if (zero? cnt)
      cnt
      (recur (dec cnt)))))

(test 10)
