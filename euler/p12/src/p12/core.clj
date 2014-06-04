(ns p12.core)

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

(defn primeFactors
  ([n]
     (primeFactors n primes))
  ([n ps]
     (let [f (first ps)
           r (rest ps)]
       (cond
        (< n f) []
        (divisible? n f) (cons f (lazy-seq (primeFactors (/ n f) ps)))
        :else (recur n r)))))

(defn collect
  ([xs]
     (if (empty? xs)
       []
       (collect (rest xs) (first xs) 1)))
  ([xs current count]
     (if (empty? xs)
       [[current count]]
       (let [[f & rest] xs]
         (if (== current f)
           (recur rest current (inc count))
           (cons [current count] (lazy-seq (collect rest f 1))))))))

(defn countFactors [n]
  (reduce * (map #(inc (get % 1)) (collect (primeFactors n)))))

(defn foo
  "I don't do a whole lot."
  [x]
  (println x "Hello, World!"))

(def triangle-numbers
  (let [impl
        (fn impl [n i]
          (cons
           n
           (lazy-seq
            (impl (+ n i) (inc i)))))]
    (impl 1 2)))

(def triangle-factors (map #(vector % (countFactors %)) triangle-numbers))

(defn -main [& args]
  (println (first (drop-while #(> 500 (get % 1)) triangle-factors))))


