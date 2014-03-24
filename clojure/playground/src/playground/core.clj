(ns playground.core)

(require '[clojure.core.async :as async :refer :all])

(defn isTeiler [n t]
  (= (mod n t) 0))

(defn isPrime [n]
  (empty? (filter (partial isTeiler n) (range 2 n))))

(defn startPrimeWorker [workChan resultChan n]
  (go
   (println "Started Worker " n)
   (loop []
     (let [p (<! workChan)]
       (if (nil? p)
         (println "Stopped Worker " n)
         (do (when (isPrime p)
               (>! resultChan p))
             (recur)))))))

(defn startWorkers [workChan resultChan]
  (dotimes [i 2]
    (startPrimeWorker workChan resultChan i)))

(defn startPrintResults [resultChan]
  (go-loop []
           (let [r (<! resultChan)]
             (if (nil? r)
               (println "Stoppen Printer")
               (do
                 (println "Result: " r)
                 (recur))))))

(defn makeTasks [workChan min max]
  (go
   (doseq [i (range min (inc max))]
        (>! workChan i))))

(makeTasks workChan 1000000 1000100)
(startPrintResults resultChan)
(>!! resultChan 23)
(startWorkers workChan resultChan)
(startPrimeWorker workChan resultChan 23)

(close! workChan)
(isPrime 11)

(def workChan (chan))
(def resultChan (chan))

(dotimes [i 2]
  )


;(def pChan (chan))
;
;(go (let [running (ref true)]
;      (while @running
;        (let [s (<! pChan)]
;          (if (nil? s)
;            (dosync (ref-set running false))
;            (println "Message: " s))))
;      (println "Stopped")))
;
;(>!! pChan "Hello")
;
;(close! pChan)
;
;(doc loop)
;
;(doc while)
;(doc ref)
;(def c (go 23))
;
;(<!! c)
;(doc <!!)
;
;(doc go)
