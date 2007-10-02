
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Old stuff below
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Using port from CLOCC
;;
;; http://cl-cookbook.sourceforge.net/sockets.html: The socket functions provided by PORT currently work without modifications on a wide range of Common Lisp implementations (Allegro, Lispworks, CLISP, CMU CL, SBCL, GCL).
;;

;; see http://cl-cookbook.sourceforge.net/sockets.html

(port:dotted-to-ipaddr "128.18.65.4")


;; !! first start OzServer in a shell..

(defparameter port 50000)		; present default of OzServer
;(defparameter port 5001)
;; create client socket which connects to OzServer 
;; my-socket is a stream which understands the normal stream interface (e.g. format and read)
(defparameter my-socket (port:open-socket "localhost" port))

;; 
;; now do it! 
;;
(format my-socket "{Browse 'it works!!'}")
;; must be called in order to get stream buffer emptied and thus really output 
(force-output my-socket)
;; ta-dah! 


;; expression (returns via stream)
(progn 
  (format my-socket "%!expression
3")
  (force-output my-socket))

(progn 
  (format my-socket "%!expression
label(x y test:4.0 * 3.1)")
  (force-output my-socket))

(progn 
  (format my-socket "%!expression
label(test:4.0 * 3.1)")
  (force-output my-socket))

; reading the stream just blocks..
; but input is received at least when OzServer is killed...
(read my-socket)


(inspect my-socket)



(progn 
  (format my-socket "%!expression
hi
")
  (force-output my-socket))

(read-line my-socket)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tmp OzServer 
;;

;; !! first start OzServer in a shell..

(defparameter my-socket (port:open-socket "localhost" 5003))

;; 
;; now do it! 
;;
(format my-socket "Hi server!")
;; must be called in order to get stream buffer emptied and thus really output 
(force-output my-socket)
;; ta-dah! 

; reading the stream just blocks..
; but input is received at least when OzServer is killed...
(read my-socket)

(progn 
  (format my-socket "%!expression
\"3 \"")
  (force-output my-socket))


(format my-socket "{Browse 'it works!!'}")
;; must be called in order to get stream buffer emptied and thus really output 
(force-output my-socket)
;; ta-dah! 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Using usocket
;;
;; Problem: reading results into Lisp seems not to work: problem probably solved when I added newline to each result output by server...
;;
 
;; !! first start OzServer in a shell..

;; usocket can be loaded via ADSF: see $LISP/LW-init.lisp 
;; NB: usocket and ADSF are not loaded by default!

(defparameter port 50000)		; present default of OzServer
;(defparameter port 5000)
;; create client socket which connects to OzServer 
(defparameter my-socket (usocket:socket-connect "localhost" port))
;; my-stream understands the normal stream interface (BASE-CHAR input and output stream)
(defparameter my-stream (usocket:socket-stream my-socket))


#| ;; example from $USOCKETDIR/test/test-usocket.lisp
(deftest socket-stream.1
  (with-caught-conditions (nil nil)
    (let ((sock (usocket:socket-connect "common-lisp.net" 80)))
      (unwind-protect
          (progn
            (format (usocket:socket-stream sock)
                    "GET / HTTP/1.0~A~A~A~A"
                    #\Return #\Newline #\Return #\Newline)
            (force-output (usocket:socket-stream sock))
            (read-line (usocket:socket-stream sock)))
        (usocket:socket-close sock))))
  #.(format nil "HTTP/1.1 200 OK~A" #\Return) 
  nil)
|# 

;; 
;; now do it! 
;;
(format my-stream "{Browse 'it works!!'}")
;; must be called in order to get stream buffer emptied and thus really output 
(finish-output my-stream)
; (force-output my-stream)
;; ta-dah! 


;; expression (returns via stream)
(progn 
  (format my-stream "%!expression
1+2")
  (force-output my-stream))

; reading the stream just blocks..
; (read my-stream)
;; process browser reports: waiting for socket input..
(read-line (usocket:socket-stream my-socket)) 

(inspect my-stream)



;; oz file feeding


;; browsing (do I really need this?)
(progn 
  (format my-stream "declare X=3")
  (finish-output my-stream))
(progn 
  (format my-stream "%!browse
X+4")
  (finish-output my-stream))



;; at the end..
(usocket:socket-close my-socket)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Using LW native socket interface
;;
 

