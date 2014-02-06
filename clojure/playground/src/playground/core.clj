(ns playground.core)

(println "Hello Wprld!")

;(require '[clojure.core.async :as async :refer :all])
;
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
