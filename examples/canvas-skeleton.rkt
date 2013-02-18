#lang r5rs
(#%require "../canvas.rkt")
(#%require (only racket/base error)) ;for error


; Auxiliary procedures
; --------------------

;Sends a message (with optional parameters) to an oo-based implementation of an ADT
(define (send-message object message . parameters)
  (let ((procedure (object message)))
    ;Assumes the object's dispatcher always returns a procedure 
    (apply procedure parameters)))

; ADT tagged data
; ---------------

; META: Example of a procedure-based ADT

; Constructors
(define (make-tagged tag data)
  (cons tag data))

; Predicates
(define (tagged? tagged)
  (pair? tagged))

(define (tagged-as? tagged tag)
  (and (tagged? tagged)
       (eq? (tagged-tag tagged tag))))

; Selectors
(define (tagged-tag x)
  (car x))

(define (tagged-data x)
  (cdr x))

; Mutators
(define (tagged-data! x newvalue)
  (set-cdr! x newvalue))


; Coordinates
; -----------

; META: Example of a procedure-based ADT

; Constructors
(define (make-coordinates x y)
  (make-tagged 'coordinates (cons x y)))

; Predicates
(define (coordinates? coos)
  (tagged-as? coos 'coordinates))

; Selectors
(define (coordinates-x coos)
  (car (tagged-data coos)))

(define (coordinates-y coos)
  (cdr (tagged-data coos)))

; Mutators
(define (coordinates-x! coos x)
  (set-car! (tagged-data coos) x))

(define (coordinates-y! coos y)
  (set-cdr! (tagged-data coos) y))

;META: the following functions are very similar, this could be improved
(define (coordinates-inc-y! coos increase)
  (coordinates-y! coos (+ (coordinates-y coos) increase)))

(define (coordinates-dec-y! coos decrease)
  (coordinates-y! coos (- (coordinates-y coos) decrease)))

(define (coordinates-inc-x! coos increase)
  (coordinates-x! coos (+ (coordinates-x coos) increase)))


; Speed
; -----------
; META: This ADT is very similar to the previous one and could be generalised.
; Speed and coordinates would then be instances of this general ADT.

; Constructors
(define (make-speed x y)
  (make-tagged 'speed (cons x y)))

; Predicates
(define (speed? speed)
  (tagged-as? speed 'speed))

; Selectors
(define (speed-x speed)
  (car (tagged-data speed)))

(define (speed-y speed)
  (cdr (tagged-data speed)))

; Mutators
(define (speed-x! speed x)
  (set-car! (tagged-data speed) x))

(define (op-x speed arg op)
  (make-speed (op (speed-x speed) arg)
              (speed-y speed)))

(define (op-y speed arg op)
  (make-speed  (speed-x speed)
               (op (speed-y speed) arg)))

(define (inc-y speed inc)
  (op-y speed inc +))

(define (dec-y speed inc)
  (op-y speed inc -))

(define (inc-x speed inc)
  (op-x speed inc +))

(define (dec-x speed inc)
  (op-x speed inc -))

(define (speed-y! speed y)
  (set-cdr! (tagged-data speed) y))

; Avatar
; ----
; Instantiates a (ball) avatar with the given radius and x-coordinate
(define (make-avatar radius x color)
  (let ( ; current position; as value, take the avatar's initial position
         ; current speed; as value, take the avatar's initial speed
         ; avatar's speed in case of user input (no horizontal speed, only vertical "up" speed)
         ;; Start
         (curr-pos (make-coordinates x 100))
         (curr-vel (make-speed 0 20))
         (jump-vel-y 10)
         ;; End
         )

    ; Still needed: selectors, mutators, .. for ADT fields
    ;; Start
    (define (get-position) curr-pos)
    (define (get-speed)    curr-vel)
    (define (get-radius)   radius)
    (define (get-color)    color)

    (define (set-position! new-pos)
      (set! curr-pos new-pos))
    (define (set-speed! new-vel)
      (set! curr-vel new-vel))

    (define (up!)
      (let ((new-vel (make-speed (speed-x curr-vel) jump-vel-y)))
        (set! curr-vel new-vel)))
    ;; End

    ;Draws the avatar on the given game UI
    (define (draw ui)
      ;does not draw directly, but asks the UI to draw the avatar instead
      ;this way, the game can be configured with a different UI
      (send-message ui 'draw-avatar dispatch))

    ;Processes the events (= user input, sensor input) recorded by event-recorder
    (define (process-events event-recorder)
      (let ((event (send-message event-recorder 'last-recorded-event)))
        ;TODO: this might be slow as there are many events not related to an avatar
        (case event
          ((up) (up!)) ;Key-up event was recorded; give avatar a vertical (up) speed

          (else 'do-nothing)))) ;Not an event a avatar reacts to

    (define (dispatch message)
      (case message
        ((position) get-position)
        ((set-position!) set-position!)
        ((speed) get-speed)
        ((set-speed!) set-speed!)
        ((up!) up!)
        ((radius) get-radius)
        ((color) get-color)
        ((draw) draw)
        ((process-events) process-events)

        (else (error 'avatar "unknown message ~a" message))))
    dispatch))

;-----------------------------------------------------------------------------------------------------
; Instantiates a obstacle with the x- and y-coordinate
(define (make-obstacle width height x y color)
  (let (;current position; as value, take the obstacle's initial position
        ;current speed; as value, take the obstacle's initial (constant) speed (it moves to the left!!)
        ;; Start
        (curr-pos (make-coordinates x y))
        (curr-vel (make-speed -1 0))
        ;; End
        )

    ;Still needed: selectors, mutators, .. for ADT fields
    ;; Start
    (define (get-position) curr-pos)
    (define (get-speed)    curr-vel)
    (define (get-width)    width)
    (define (get-height)   height)
    (define (get-color)    color)

    (define (set-position! new-pos)
      (set! curr-pos new-pos))
    ;; End

    ;Draws the obstacle on the given game UI
    (define (draw ui)
      ;does not draw directly, but asks the UI to draw the obstacle instead
      ;this way, the game can be configured with a different UI
      (send-message ui 'draw-obstacle dispatch))

    (define (dispatch message)
      (case message
        ((position) get-position)
        ((set-position!) set-position!)
        ((speed) get-speed)
        ((width) get-width)
        ((height) get-height)
        ((color) get-color)
        ((draw) draw)

        (else (error 'obstacle "unknown message ~a" message))))
    dispatch))

; Canvas UI
; ---------

; META: Example of an OO-based ADT

; UI that draws on a window using the Canvas.rkt library
(define (make-canvas-ui)
  (let ((window-w 800)
        (window-h 600)
        (window-c white))

    ;Draws the given avatar
    (define (draw-avatar avatar)
      ;TODO: write the code for drawing on avatar on the screen
      ;see Canvas.rkt
      ;; Start
      (let ((pos    (send-message avatar 'position))
            (radius (send-message avatar 'radius))
            (color  (send-message avatar 'color)))
        (fill-ellipse!
          (coordinates-x pos)
          (coordinates-y pos)
          radius
          radius
          color))
      ;; End
      )

    ;Draws the given obstacle
    (define (draw-obstacle obstacle)
      ;TODO: write the code for drawing on obstacle on the screen
      ;see Canvas.rkt
      ;; Start
      (let ((pos    (send-message obstacle 'position))
            (width  (send-message obstacle 'width))
            (height (send-message obstacle 'height))
            (color  (send-message obstacle 'color)))
        (fill-rectangle!
          (coordinates-x pos)
          (coordinates-y pos)
          width
          height
          color))
      ;; End
      )

    (define (dispatch message)
      (case message
        ((draw-avatar) draw-avatar)
        ((draw-obstacle) draw-obstacle)
        ((width) (lambda () window-w))
        ((height) (lambda () window-h))

        (else (error 'canvas-ui "unknown message ~a" message))))
    dispatch))


; Physics Engine
; --------------
(define (make-physics-engine gravity)
  (let ((previous-time (current-time))
        (dt 0))

    ; Calculate new position, based on given position & speed
    (define (move-coordinates position speed)
      (let ((px (coordinates-x position))
            (py (coordinates-y position))
            (vx (speed-x speed))
            (vy (speed-y speed)))
        (make-coordinates
          (+ px (* vx dt))
          (+ py (* vy dt)))))

    ;Update the current time frame
    (define (update-time!)
      (let ((time (current-time)))
        (set! dt (/ (- time previous-time) 30))
        (set! previous-time time)))

    ;Change the speed, based on gravity
    (define (update-speed speed)
      (make-speed
        (speed-x speed)
        (- (speed-y speed) (* gravity dt))))

    ;Move avatar
    (define (move-avatar avatar)
      ;; Start
      (let* ((curr-pos (send-message avatar 'position))
             (curr-vel (send-message avatar 'speed))
             (new-vel  (update-speed curr-vel))
             (new-pos (move-coordinates curr-pos curr-vel)))
        (send-message avatar 'set-position! new-pos)
        (send-message avatar 'set-speed! new-vel))
      ;; End
      )

    ;Move obstacle
    (define (move-obstacle obstacle)
      ;; Start
      (let* ((curr-pos (send-message obstacle 'position))
             (curr-vel (send-message obstacle 'speed))
             (new-pos  (move-coordinates curr-pos curr-vel)))
        (send-message obstacle 'set-position! new-pos))
      ;; End
      )


    (define (dispatch message)
      (case message
        ((move-avatar) move-avatar)
        ((move-obstacle) move-obstacle)
        ((update-time!) update-time!)

        (else (error 'physics-engine "unknown message ~a" message))))

    dispatch))


; Canvas Event Recorder
; ---------------------

; Using Canvas.rkt, converts the last keyboard input to a game event
(define (make-canvas-event-recorder)
  (let ((event 'no-event))

    ;Initializes the recorder by linking it to Canvas.rkt
    (define (initialize)
      (clear)
      (on-key! 'up (lambda () (set! event 'up)))
      (on-key! 'down (lambda () (set! event 'down)))
      (on-key! 'right (lambda () (set! event 'right)))
      (on-key! 'left (lambda () (set! event 'left))))

    ;Erases the last recorded event by resetting it to a dummy value
    (define (clear)
      (set! event 'no-event))

    ;Returns the last recorded event
    ;TODO: in case of multiple input devices, recording a single keystroke won't suffice 

    (define (last-recorded-event)
      event)

    (initialize)

    (define (dispatch message)
      (case message
        ((clear) clear)
        ((last-recorded-event) last-recorded-event)
        (else (error 'canvas-event-recorder "unknown message ~a" message))))
    dispatch))


; Game Loop
; ---------

; Creates a game with the following parameters
; - game-avatar: avatar in the game
; - game-obstacles: obstacles in the game
; - ui: the ui the game will be drawn on
; - event-recorder: the source of events for the game (e.g., keyboard input -> event)

;TODO: this loop clears and redraws the entire screen, even if nothing has changed
(define (make-game-loop game-avatar game-obstacles ui physics-engine event-recorder)

  ;One iteration of the game loop
  (define (game-advancer)
    ;Clear (erase) the user interface
    ;...
    ;Set how much time has passed since last iteration
    ;...

    ;For each obstacle,
    (for-each (lambda (obstacle)
                ;Think what needs to be done in each game loop for each obstacle!
                ;; Start
                (send-message physics-engine 'move-obstacle obstacle)
                (send-message obstacle 'draw ui)
                ;; End
                )
              game-obstacles)

    ;For the avatar, thinks what needs to be done in each game loop.
    ;; Start
    (send-message game-avatar 'process-events event-recorder)
    (send-message event-recorder 'clear)

    (send-message physics-engine 'move-avatar game-avatar)
    (send-message game-avatar 'draw ui)

    (send-message physics-engine 'update-time!)
    ;; End

    ;Clear the recorded user input events
    ; (send-message event-recorder 'clear))
    )

  (define (start)
    (start-game-loop game-advancer))

  (define (dispatch message)
    (case message
      ((start) start)

      (else (error 'game-loop "unknown message ~a" message))))
  dispatch)


;Start a game with one avatar and two obstacles
(send-message (make-game-loop
                ;; Start
                (make-avatar 20 250 blue)
                (list (make-obstacle 100 100 400 0 red) (make-obstacle 100 300 550 0 red))
                (make-canvas-ui)
                (make-physics-engine 0.6)
                (make-canvas-event-recorder)
                ;; End
                )
              'start)

