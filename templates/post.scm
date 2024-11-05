;; ;; templates/post.scm
;; (use-modules (haunt utils)
;;              (haunt post)
;;              (sxml simple)
;;              (srfi srfi-19))  ; For date and time procedures

;; ;; Define the post-title function
;; (define (post-title post)
;;   (assq-ref (post-metadata post) 'title))

;; (define (post-template post)
;;   `(div
;;      (p (@ (class "back-to-home")) (a (@ (href "/index.html")) "Back to Home"))  ; Add "Back to Home" link at the top
;;      (h2 ,(post-title post))
;;      (p (@ (class "post-meta"))
;;         "Posted on " ,(date->string (post-date post) "~Y-~m-~d") " by " ,(assq-ref (post-metadata post) 'author))
;;      (div (@ (class "content")) ,@(post-sxml post))
;;      (p (@ (class "back-to-home")) (a (@ (href "/index.html")) "Back to Home"))))  ; Add "Back to Home" link at the bottom

;; ;; templates/post.scm
;; (use-modules (haunt utils)
;;              (haunt post)
;;              (sxml simple)
;;              (srfi srfi-19))  ; For date and time procedures

;; ;; Define the post-title function
;; (define (post-title post)
;;   (assq-ref (post-metadata post) 'title))

;; (define (post-template post)
;;   `(div (@ (class "post-container"))
;;      (h2 ,(post-title post))
;;      (p (@ (class "post-meta"))
;;         "Posted on " ,(date->string (post-date post) "~Y-~m-~d") " by " ,(assq-ref (post-metadata post) 'author))
;;      (div (@ (class "content")) ,@(post-sxml post))
;;      (p (@ (class "back-to-home")) (a (@ (href "/index.html")) "Back to Home"))))


;; templates/post.scm
(use-modules (haunt utils)
             (haunt post)
             (sxml simple)
             (srfi srfi-19))  ; For date and time procedures

;; Define the post-title function
(define (post-title post)
  (assq-ref (post-metadata post) 'title))

(define (post-template post)
  `(div (@ (class "post-wrapper")) ; Added an outer wrapper class for more flexibility
     (div (@ (class "post-container"))
       ;; Post Title - Now clickable to return to the post's URL
       (h2 (a (@ (href ,(post-url post)) (class "post-title-link")) ,(post-title post)))

       ;; Post Meta Information
       (p (@ (class "post-meta"))
          "Posted on " ,(date->string (post-date post) "~Y-~m-~d") " by " ,(assq-ref (post-metadata post) 'author))

       ;; Post Content
       (div (@ (class "content vinyl-style")) ,@(post-sxml post))  ; Updated class for consistent style

       ;; Back to Home Link
       (p (@ (class "back-to-home")) (a (@ (href "/index.html")) "Back to Home")))))
