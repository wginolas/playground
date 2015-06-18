(ns react-asteroids.core
  (:require [om.core :as om :include-macros true]
            [om.dom :as dom :include-macros true]))

(enable-console-print!)

(def app-state (atom {:text "Hello world!"}))

(def pressed-keys (atom #{}))

(defn image [x y width height src]
  (dom/div #js {:style #js {:left (str x "px")
                            :top (str y "px")
                            :position "absolute"
                            :width (str width "px")
                            :height (str height "px")
                            :background-image image}}))

(defn rocket [x y]
  (image x y 64 64 "rocket.png"))

(om/root
  (fn [app owner]
    (reify om/IRender
      (render [_]
        (dom/h1 nil (:text app)))))
  app-state
  {:target (. js/document (getElementById "app"))})

(.addEventListener js/document "keydown"
                   (fn [event]
                     (swap! pressed-keys #(conj % (.-key event)))))

(.addEventListener js/document "keyup"
                   (fn [event]
                     (swap! pressed-keys #(disj % (.-key event)))))
