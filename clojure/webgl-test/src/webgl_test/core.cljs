(ns webgl-test.core
  (:require ))

(enable-console-print!)

(println "Edits to this text should show up in your developer console.")

;; define your app data so that it doesn't get over-written on reload

(defonce app-state (atom {:text "Hello world!"}))

(defn getGlContext []
  (.getContext (.getElementById js/document "canvas") "webgl"))

(def gl (getGlContext))

(defn load-shader [type source]
  (let [shader (.createShader gl type)]
    (.shaderSource gl shader source)
    (.compileShader gl shader)
    shader))

(defn setup-shaders [vertexShaderSource fragmentShaderSource attrs]
  (let [vertexShader (load-shader (.-VERTEX_SHADER gl) vertexShaderSource)
        fragmentShader (load-shader (.-FRAGMENT_SHADER gl) fragmentShaderSource)
        shaderProgram (.createProgram gl)]
    (.attachShader gl shaderProgram vertexShader)
    (.attachShader gl shaderProgram fragmentShader)
    (.linkProgram gl shaderProgram)
    (.useProgram gl shaderProgram)
    (into {} (cons
              [:shader shaderProgram]
              (map #(vector (keyword %1) (.getAttribLocation gl shaderProgram %1)) attrs)))))

(def shader (setup-shaders
             (str "attribute vec3 aVertexPosition; \n"
                  "void main() {\n"
                  "    gl_Position = vec4(aVertexPosition, 1.0);\n"
                  "}\n")
             (str "precision mediump float;\n"
                  "void main() {\n"
                  "    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);\n"
                  "}\n")
             ["aVertexPosition"]))

(println shader)

(defn float-32-array [fs]
  (js/Float32Array. (apply array fs)))

(defn setup-buffers []
  (let [vertex-buffer (.createBuffer gl)
        vertices (float-32-array [ 0.0  0.5  0.0
                                  -0.5 -0.5  0.0
                                  0.5 -0.5  0.0])]
    (.bindBuffer gl (.-ARRAY_BUFFER gl) vertex-buffer)
    (.bufferData gl (.-ARRAY_BUFFER gl) vertices (.-STATIC_DRAW gl))
    {:buffer vertex-buffer :item-size 3 :item-count 3}))

(def vertex-buffer (setup-buffers))

(defn draw []
  (.viewport gl 0 0 (.-drawingBufferWidth gl) (.-drawingBufferHeight gl))
  (.clear gl (.-COLOR_BUFFER_BIT gl))
  (.vertexAttribPointer gl (shader :aVertexPosition) (vertex-buffer :item-size) (.-FLOAT gl) false 0 0)
  (.enableVertexAttribArray gl (shader :aVertexPosition))
  (.drawArrays gl (.-TRIANGLES gl) 0 (vertex-buffer :item-count)))

(defn ^:export startup []
  (.clearColor gl 1 0 0 1)
  (draw))


(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
  (startup)
)
