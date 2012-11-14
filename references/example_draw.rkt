#lang r5rs 
;Loading the library (note that you can't use the usual import!)
(#%require "../canvas.rkt")

;basic drawing operations
(fill-rectangle! 0   0 20 20 red)
(fill-ellipse!   45 45 50 50 green)
(draw-line!      45 45 20 20 blue)
(draw-text!      200 200 "Jaarproject 2011-2012" green)
(put-pixel!      200 200 blue)

;defining colors
(define my-blue  (make-color 0 0 15))
(define my-green (make-color 0 15 0))
(define my-red   (make-color 15 0 0))
(draw-line!      45 45 45 (+ 50 45) my-green)

;listening to the keyboard
(on-key! 'left (lambda () (display "left\n")))
(on-key! 'right (lambda () (display "right\n")))
(on-key! 'up (lambda () (display "up\n")))
(on-key! 'down (lambda () (display "down\n")))
(on-key! #\a (lambda () (display "pressed a\n")))
(on-key! #\space (lambda () (display "pressed space\n")))

;current time in 100s of a second
(display (current-time))
(newline)

;starting a game-loop
(define count 0)
(start-game-loop (lambda () 
                   (if (< count 10)
                       (begin
                         (set! count (+ count 1))
                         (display (current-time))
                         (newline)))))