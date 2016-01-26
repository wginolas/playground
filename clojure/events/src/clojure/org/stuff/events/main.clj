(ns org.stuff.events.main
    (:require [neko.activity :refer [defactivity set-content-view!]]
              [neko.debug :refer [*a]]
              [neko.notify :refer [toast]]
              [neko.resource :as res]
              [neko.find-view :refer [find-view]]
              [neko.threading :refer [on-ui]]
              [neko.ui :refer [config]]
              [clojure.string :refer [join]])
    (:import android.widget.EditText
             android.widget.TextView
             (java.util Calendar)
             (android.app Activity)
             (android.app DatePickerDialog DatePickerDialog$OnDateSetListener)
             (android.app DialogFragment)))

;; https://github.com/alexander-yakushev/events/blob/master/tutorial.md

;; We execute this function to import all subclasses of R class. This gives us
;; access to all application resources.
(res/import-all)

(def listing (atom (sorted-map)))

(defn get-elmt [activity elmt]
  (str (.getText ^TextView (find-view activity elmt))))

(defn set-elmt [activity elmt s]
  (on-ui (config (find-view activity elmt) :text s)))

(defn format-events [events]
  (->> (map (fn [[location event]]
              (format "%s - %s\n" location event))
            events)
       (join "                      ")))

(defn format-listing [lst]
  (->> (map (fn [[date events]]
              (format "%s - %s" date (format-events events)))
            lst)
       join))

(defn update-ui [activity]
  (set-elmt activity ::listing (format-listing @listing))
  (set-elmt activity ::location "")
  (set-elmt activity ::name ""))

(defn add-event [activity]
  (let [date-key (try
                   (read-string (get-elmt activity ::date))
                   (catch RuntimeException e "Date string is empty!"))]
    (when (number? date-key)
      (swap! listing update-in [date-key] (fnil conj [])
             [(get-elmt activity ::location) (get-elmt activity ::name)])
      (update-ui activity))))

(declare date-picker)
(defn show-picker [^Activity activity dp]
  (. dp show (. activity getFragmentManager) "datePicker"))

(defn main-layout [activity]
  [:linear-layout {:orientation :vertical}
   [:edit-text {:hint "Event name" :id ::name}]
   [:edit-text {:hint "Event location" :id ::location}]
   [:linear-layout {:orientation :horizontal}
    [:edit-text {:hint "Event date" :id ::date}]
    [:button {:text "..."
              :on-click (fn [_]
                          (show-picker activity (date-picker activity)))}]]
   [:button {:text "+ Event"
             :on-click (fn [_]
                         (add-event activity))}]
   [:text-view {:text (format-listing @listing) :id ::listing}]])

;; (get-elmt (*a) ::name) 

(defn date-picker [activity]
  (proxy [DialogFragment DatePickerDialog$OnDateSetListener] []
    (onCreateDialog [savedInstanceState]
      (let [c (Calendar/getInstance)
            year (.get c Calendar/YEAR)
            month (.get c Calendar/MONTH)
            day (.get c Calendar/DAY_OF_MONTH)]
        (DatePickerDialog. activity this year month day)))
    (onDateSet [view year month day]
      (set-elmt activity ::date
                (format "%d%02d%02d" year (inc month) day)))))

;; This is how an Activity is defined. We create one and specify its onCreate
;; method. Inside we create a user interface that consists of an edit and a
;; button. We also give set callback to the button.
(defactivity org.stuff.events.MainActivity
  :key :main

  (onCreate [this bundle]
    (.superOnCreate this bundle)
    (neko.debug/keep-screen-on this)
    (on-ui
     (set-content-view! (*a) (main-layout (*a)))
     (set-elmt (*a) ::listing (format-listing @listing)))

    ))
