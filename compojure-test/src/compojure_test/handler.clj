(ns compojure-test.handler
  (:use compojure.core)
  (:require [compojure.handler :as handler]
            [compojure.route :as route]))

(defroutes app-routes
  (GET "/" [] "Hello World1")
  (GET "/map" [] {"x" 3
                  "y" "a"})
  (route/resources "/")
  (route/not-found "Not Found"))

(def app
  (handler/site app-routes))
