(defproject cljs-playground "0.1.0-SNAPSHOT"
  :description "FIXME: write this!"
  :url "http://example.com/FIXME"
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [org.clojure/clojurescript "0.0-2138"]
                 [ring "1.2.1"]
                 [compojure "1.1.6"]
                 [enlive "1.1.5"]]
  :plugins [[lein-cljsbuild "0.3.2"]
            [lein-ring "0.8.3"]
            [com.cemerick/austin "0.1.3"]]
  :repl-options {:init-ns cljs-playground.server}
  :hooks [leiningen.cljsbuild]
  :source-paths ["src/clj"]
  :cljsbuild { 
    :builds {
      :main {
        :source-paths ["src/cljs"]
        :compiler {:output-to "resources/public/js/cljs.js"
                   :optimizations :simple
                   :pretty-print true}
        :jar true}}}
  :main cljs-playground.server
  :ring {:handler cljs-playground.server/app})

