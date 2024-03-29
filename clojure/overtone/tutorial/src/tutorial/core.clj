(ns tutorial.core)

;(use 'overtone.live)
(use 'overtone.core)
(boot-external-server)
(use 'overtone.inst.sampled-piano)
(use 'overtone.inst.synth)
(use 'overtone.midi)
(use 'overtone.studio.midi)
;(midi-sources)
;(connected-midi-devices)
(midi-connected-receivers)
(event-debug-on)
(event-debug-off)
(def player (midi-poly-player sampled-piano))
(midi-poly-player sampled-piano)
;(definst foo [] (saw 220))
;(foo)
;(kill foo)

(count (freesound-searchm [:id] "LOW" :f "pack:MISStereoPiano"))

(demo (sin-osc))

(sampled-piano 60)
(piano)

(defn play-note
  [n]
  (sampled-piano n 0.5))

(defn play-notes
  [t-start delay notes]
  (doseq [[n t] (map vector notes (range))]
         (at (+ t-start (* delay t)) (play-note n)))
  )

;(defn play-notes
;  [t delay notes]
;  (let [nextT (+ t delay)
;        n (first notes)
;        nRest (rest notes)]
;
;    (when n
;     (at t (play-note n))
;     (apply-by nextT play-notes [nextT delay nRest]))))

(defn my-chord
  [n]
  (let [s (cycle (scale :c4 :major))
        n (- n 1)]
    [(nth s n)
     (nth s (+ 2 n))
     (nth s (+ 4 n))]))

(defn every-second [s]
  (if (empty? s)
    '()
    (lazy-seq (cons (first s) (every-second (rest (rest s)))))))

(play-notes (now) 100 (sort (take 4 (every-second (drop 0 (cycle (scale :c3 :major)))))))


(do
  (play-notes (+ (now)    0) 100 (my-chord 1))
  (play-notes (+ (now) 1000) 100 (my-chord 4))
  (play-notes (+ (now) 2000) 100 (my-chord 1))
  (play-notes (+ (now) 3000) 100 (sort (my-chord 5))))

(play-notes (now) 0 (my-chord 1))
(play-notes (now) 0 (chord :c4 :major))
(play-notes (now) 0 (chord :d4 :major))
(play-notes (now) 500 (chord :c4 :minor))
(play-notes (now) 500 (chord :c4 :augmented))
(play-notes (now) 500 (chord :c4 :diminished))


(do
  (play-note 60)
  (play-note 64)
  (play-note 67))

(defn play [speed notes]
  (let [t-start (now)]
    (doseq [[t n] notes]
      (at (+ t-start (* t speed)) (play-note n)))))

(defn digit-to-int [c]
  (- (int c) (int \0)))

(defn parse-numbers-impl [t s]
  (when-let [s (seq s)]
    (let [c (first s)
          r (rest s)]
      (if (= \- c)
        (recur (inc t) r)
        (lazy-seq
         (cons
          [t (digit-to-int c)]
          (parse-numbers-impl t r)))))))

(defn parse-numbers [s]
  (parse-numbers-impl 0 s))

(defn num->notes [num notes]
  (map (fn [x]
         (let [[t n] x]
           [t (nth notes n)]))
       num))

(concat)

(play 200
      (num->notes
       (parse-numbers "1-2-3")
       (scale :c4 :major)))

(play 200
      (num->notes
       (parse-numbers "135")
       (scale :c4 :major)))

(play 200
      (num->notes
       (parse-numbers "1-2-3-2")
       (sort (every-second (drop 0 (cycle (scale :c3 :major)))))))

(play-notes (now) 100 (sort (every-second (drop 0 (cycle (scale :c3 :major))))))

(when-let [x (seq (rest "34"))]
  (println x))
(tail "")
(play 1000 [[0 60] [1 61] [0 62]])

(when-let)

(definst steel-drum [note 60 amp 0.8]
  (let [freq (midicps note)]
    (* amp
       (env-gen (perc 0.01 0.2) 1 1 0 1 :action FREE)
       (+ (sin-osc (/ freq 2))
          (rlpf (saw freq) (* 1.1 freq) 0.4)))))

(definst c-hat [amp 0.8 t 0.04]
  (let [env (env-gen (perc 0.001 t) 1 1 0 1 FREE)
        noise (white-noise)
        sqr (* (env-gen (perc 0.01 0.04)) (pulse 880 0.2))
        filt (bpf (+ sqr noise) 9000 0.5)]
    (* amp env filt)))

(c-hat)
(sort (every-second (drop 0 (cycle (scale :c3 :major)))))(steel-drum)

(def piece [:E4 :F#4 :B4 :C#5 :D5 :F#4 :E4 :C#5 :B4 :F#4 :D5 :C#5])

(defn player
  [t speed notes]
  (let [n (first notes)
        notes (next notes)
        t-next (+ t speed)]
    (when n
      (at t
        (sampled-piano (note n)))
      (apply-by t-next #'player [t-next speed notes]))))

(def num-notes 1000)

(do
  (player (now) 338 (take num-notes (cycle piece)))
  (player (now) 335 (take num-notes (cycle piece))))

(stop)
