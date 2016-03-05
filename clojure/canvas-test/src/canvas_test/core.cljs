(ns canvas-test.core
  (:require ))

(enable-console-print!)

(defn random [min max]
  (- (* (- max min) (js/Math.random)) min))

;; define your app data so that it doesn't get over-written on reload
(defonce app-state
  (atom
   {:ball (map
           #({:x (random 0 100)
              :y (random 0 100)
              :dx (random -2 2)
              :dy (random -2 2)})
           (range 10))
    :width 0
    :height 0}))
(defonce animId 0)

(def canvasElement (.getElementById js/document "canvas"))
(def canvas (.getContext canvasElement "2d"))
(def width (.-width canvasElement))
(def height (.-height canvasElement))

(defn render-ball [{:keys [x y]}]
  (set! (.-fillStyle canvas) "green")
  (.fillRect canvas x y 10 10))

(defn render-balls [balls]
  (doseq [b balls]
    (render-ball b)))

(defn render [state]
  (let [{:keys [balls width height]} state]
    (set! (.-width canvasElement) width)
    (set! (.-height canvasElement) height)
    (set! (.-fillStyle canvas) "white")
    (.fillRect canvas 0 0 width height)
    (render-balls balls)))

(defn update-ball [{:keys [x y dx dy]}]
  {:x (+ x dx)
   :y (+ y dy)
   :dx (if (> x 100)
         (- (js/Math.abs dx))
         (if (< x 0)
           (js/Math.abs dx)
           dx))
   :dy (if (> y 100)
         (- (js/Math.abs dy))
         (if (< y 0)
           (js/Math.abs dy)
           dy))})

(defn update-balls [balls]
  (map update-ball balls))

(defn update-state [state]
  {:width (.-innerWidth js/window)
   :height (.-innerHeight js/window)
   :balls (update-balls (state :balls))})

(defn tick []
  (swap! app-state update-state)
  (render @app-state)
  (set! animId (.requestAnimationFrame js/window tick)))

(defn on-js-reload []
  (.cancelAnimationFrame js/window animId)
  (set! animId (.requestAnimationFrame js/window tick))
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)

(defonce setup-once
  (do
    (on-js-reload)))
