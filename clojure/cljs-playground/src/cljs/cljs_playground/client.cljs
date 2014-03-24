(ns hello-clojurescript
  (:require [clojure.browser.repl]))

(defn handle-click []
  (js/alert "Hello World!"))

(def clickable (.getElementById js/document "clickable"))
(.addEventListener clickable "click" handle-click)
