(ns hello-clojurescript
  (:require [clojure.browser.repl :as repl]))

(defn handle-click []
  (js/alert "Hello World!"))

(def clickable (.getElementById js/document "clickable"))
(.addEventListener clickable "click" handle-click)

(repl/connect "http://localhost:9000/repl")
