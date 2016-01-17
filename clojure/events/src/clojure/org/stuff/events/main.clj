(ns org.stuff.events.main
    (:require [neko.activity :refer [defactivity set-content-view!]]
              [neko.debug :refer [*a]]
              [neko.notify :refer [toast]]
              [neko.resource :as res]
              [neko.find-view :refer [find-view]]
              [neko.threading :refer [on-ui]]
              [neko.ui :refer [config]])
    (:import android.widget.EditText
             android.widget.TextView))

;; https://github.com/alexander-yakushev/events/blob/master/tutorial.md

;; We execute this function to import all subclasses of R class. This gives us
;; access to all application resources.
(res/import-all)

(defn notify-from-edit
  "Finds an EditText element with ID ::user-input in the given activity. Gets
  its contents and displays them in a toast if they aren't empty. We use
  resources declared in res/values/strings.xml."
  [activity]
  (let [^EditText input (.getText (find-view activity ::user-input))]
    (toast (if (empty? input)
             (res/get-string R$string/input_is_empty)
             (res/get-string R$string/your_input_fmt input))
           :long)))

(def listing (atom ""))

(defn main-layout [activity]
  [:linear-layout {:orientation :vertical}
   [:edit-text {:hint "Event name" :id ::name}]
   [:edit-text {:hint "Event location" :id ::location}]
   [:button {:text "+ Event"
             :on-click (fn [_]
                         (add-event activity))}]
   [:text-view {:text @listing :id ::listing}]])

(defn get-elmt [activity elmt]
  (str (.getText ^TextView (find-view activity elmt))))

(defn set-elmt [activity elmt s]
  (on-ui (config (find-view activity elmt) :text s)))

(defn add-event [activity]
  (swap! listing str (get-elmt activity ::location) " - "
         (get-elmt activity ::name) "\n")
  (set-elmt activity ::listing @listing))

;; (get-elmt (*a) ::name) 

;; This is how an Activity is defined. We create one and specify its onCreate
;; method. Inside we create a user interface that consists of an edit and a
;; button. We also give set callback to the button.
(defactivity org.stuff.events.MainActivity
  :key :main

  (onCreate [this bundle]
    (.superOnCreate this bundle)
    (neko.debug/keep-screen-on this)
    (on-ui
     (set-content-view! (*a) (main-layout (*a))))

    ))
