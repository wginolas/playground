(ns logic-test.core
   (:refer-clojure :exclude [==])
   (:use clojure.core.logic))

(defn -main [& args]
  (println "Hello World!")
  (println (run* [q]
                 (== q 1))))

;(doc membro)

