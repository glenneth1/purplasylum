(use-modules (haunt asset)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt builder flat-pages)  ; Import flat-pages builder
             (haunt reader commonmark)
             (haunt site)
             (sxml simple)    ; For HTML generation
             (srfi srfi-1)
             (srfi srfi-19)
             (ice-9 match))   ; Import match for pattern matching

;; Define the post-title function if not defined
(define (post-title post)
  (assq-ref (post-metadata post) 'title))

;; Define string-replace-substring function
(define (string-replace-substring str old new)
  (let loop ((str str) (result '()))
    (match (string-index str (string-ref old 0))
      ((? eof-object?)
       (string-concatenate-reverse (cons str result)))
      (pos
       (let ((prefix (substring str 0 pos))
             (suffix (substring str (+ pos (string-length old)))))
         (loop suffix (cons new (cons prefix result))))))))

;; Load custom templates
(load "templates/post.scm")

(define (format-date date)
  (date->string date "~Y-~m-~d"))

;; Define a function to generate the URL for a post
(define (post-url post)
  (string-append "/" (post-slug post) ".html"))

;; Define a function to extract a summary from the post content
(define (post-summary post)
  (let ((content (post-sxml post)))
    (if (null? content)
        ""
        (let ((first-paragraph (car content)))
          (if (string? first-paragraph)
              (substring first-paragraph 0 (min 200 (string-length first-paragraph)))
              (sxml->string first-paragraph))))))

;; Define the theme layout
(define (theme-layout site page-title content)
  (let ((current-year (number->string (date-year (current-date)))))
    `(html
      (head
       (meta (@ (charset "utf-8")))
       (meta (@ (name "viewport") (content "width=device-width, initial-scale=1.0, shrink-to-fit=no")))
       (link (@ (rel "stylesheet") (href "/assets/purplasylum.css")))  ; Include custom CSS
       (title ,page-title))
      (body
       (header
        (h1 (a (@ (href "/index.html")) ,(site-title site))))
       (main ,content)
       ;; (footer
       ;;  (div (@ (class "webring-text"))
       ;;       (p "I am part of the " (a (@ (href "https://systemcrafters.net") (target "_blank")) "System Crafters") " webring:"))
       ;;  (div (@ (class "craftering"))
       ;;       (a (@ (href "https://craftering.systemcrafters.net/@glenneth/previous")) "←")
       ;;       (a (@ (href "https://craftering.systemcrafters.net/")) "craftering")
       ;;       (a (@ (href "https://craftering.systemcrafters.net/@glenneth/next")) "→")))))
       ))))

;; Define the post-template function
(define (post-template post)
  `(div (@ (class "post-container"))
    (div (@ (class "post-layout"))
         ;; Main content column
         (div (@ (class "post-main"))
              ;; Post title and metadata
              (div (@ (class "post-header"))
                   (h2 ,(post-title post))
                   (p (@ (class "post-meta"))
                      "Posted on " ,(format-date (post-date post))
                      " by " ,(assq-ref (post-metadata post) 'author)))

              ;; Post content
              (div (@ (class "content vinyl-style")) ,@(post-sxml post))

              ;; Back to home link
              (p (@ (class "back-to-home")) (a (@ (href "/index.html")) "Back to Home")))

         ;; Metadata sidebar
         (div (@ (class "post-sidebar"))
              (div (@ (class "metadata-card"))
                   (h3 "Album Info")
                   (div (@ (class "metadata-grid"))
                        (div (@ (class "metadata-item"))
                             (span (@ (class "metadata-label")) "Release Date")
                             (span (@ (class "metadata-value")) ,(let ((release-date (string-match "Released ([0-9]{2}-[A-Z]{3}-[0-9]{4})" (post-ref post 'content))))
                                                                   (if release-date
                                                                       (match:substring release-date 1)
                                                                       "N/A")))
                             (div (@ (class "metadata-item"))
                                  (span (@ (class "metadata-label")) "Label")
                                  (span (@ (class "metadata-value")) ,(let ((label (string-match "on ([^\n]+)" (post-ref post 'content))))
                                                                        (if label
                                                                            (match:substring label 1)
                                                                            "N/A")))
                                  (div (@ (class "metadata-item"))
                                       (span (@ (class "metadata-label")) "Genre")
                                       (span (@ (class "metadata-value")) ,(string-join (assq-ref (post-metadata post) 'tags) ", ")))
                                  (div (@ (class "metadata-item rating"))
                                       (span (@ (class "metadata-label")) "Rating")
                                       (div (@ (class "vinyl-rating"))
                                            (div (@ (class "vinyl-disc")))
                                            (div (@ (class "vinyl-disc")))
                                            (div (@ (class "vinyl-disc")))
                                            (div (@ (class "vinyl-disc")))
                                            (div (@ (class "vinyl-disc")))))))))))))

;; Define the custom theme with a consistent layout for index
(define my-theme
  (theme #:name "My Custom Theme"
         #:layout theme-layout
         #:post-template post-template
         #:collection-template
         (lambda (site title posts prefix)
           `(div (@ (class "content"))
             (h2 ,title)
             (ul
              ,@(map (lambda (post)
                       `(li
                         (article
                          (header
                           (h3 (a (@ (href ,(post-url post))) ,(post-title post))))
                          (p (@ (class "date")) ,(format-date (post-date post)))
                          (div (@ (class "post-summary")) ,(post-summary post))
                          (p (a (@ (href ,(post-url post))) "Read more...")))))
                     posts))))))

;; Site configuration
(site #:title "Purplasylum"
      #:domain "purplasylum.net"
      #:default-metadata
      '((author . "Glenn Thompson")
        (email  . "glenn@purplasylum.net"))
      #:readers (list commonmark-reader)
      #:builders (list 
                  (flat-pages "pages" #:template theme-layout #:prefix "")
                  (blog #:theme my-theme
                        #:collections `(("Recent Posts" "posts.html" ,posts/reverse-chronological))
                        #:prefix "posts")
                  (static-directory "images")
                  (static-directory "assets")))
