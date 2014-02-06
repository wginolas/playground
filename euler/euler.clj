(defn square [x]
  (* x x))

(defn divisible? [n t]
  (== (mod n t) 0))

(def primes
  (concat 
   [2 3 5 7]
   (lazy-seq
    (let [primes-from
	  (fn primes-from [n [f & r]]
	    (if (some #(zero? (rem n %))
		      (take-while #(<= (* % %) n) primes))
	      (recur (+ n f) r)
	      (lazy-seq (cons n (primes-from (+ n f) r)))))
	  wheel (cycle [2 4 2 4 6 2 6 4 2 4 6 6 2 6  4  2
			6 4 6 8 4 2 4 2 4 8 6 4 6 2  4  6
			2 6 6 4 2 4 6 2 6 4 2 4 2 10 2 10])]
      (primes-from 11 wheel)))))

(defn factors [n]
  (filter (partial divisible? n) (range 1 (inc n))))

(def count
  ((fn countImpl [i]
     (println i)
     (lazy-seq (cons i (countImpl (inc i))))) 0))

(reduce * (take 9 primes))
(take 25 primes)
(doc lazy-seq)
(* (.pow (biginteger 2) 166) 9)
(reduce * (map bigint (range 1 (inc 1000))))
(doc exp)
(doc apply)
(factors (* 11 11 5))
(divisible? 10 10)
(range 1 11)
(doc filter)
(doc partial)
( (partial + 1) 2)
