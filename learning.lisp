 (define (square x) (* x x))
 
 (square 5)
 
 (define (sum-of-square x y)
     (+ (square x) (square y)))
 
 (sum-of-square 3 5)
 
 (define (max x y)
     (if (< x y)
         y
         x))
     
(define (max3 x y z)
    (sum-of-square (max x y) (max (max x y) z)))

(max3 4 2 3)
