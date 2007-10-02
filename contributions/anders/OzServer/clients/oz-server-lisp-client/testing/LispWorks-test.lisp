(in-package :oz)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Communication between LW and OzServer 
;;


;; start OzServer in a shell and establish connection
(run-oz)				

;; alternative way to start OzServer in a shell (alternatively, first run start-oz-server and a bith later then run connect-to-oz)
; (start-oz-server :oz-server "~/.oz/1.3.1/bin/OzServer" :port 5010)
; (connect-to-oz :port 5010)

(+ (feed-expression "1 + 3") 
   2)
; -> 6

;; see file ./general-test.lisp for further tests

(quit-oz)

