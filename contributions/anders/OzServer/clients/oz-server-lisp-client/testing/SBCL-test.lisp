(in-package :oz)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Communication between SBCL and OzServer
;;

#|
;; NB: the convenient (run-oz) does not work yet with SBCL

;; start OzServer in a shell and establish connection
; (run-oz) ; does not work: PORT:MAKE-PROCESS: not implemented for SBCL [1.0.1]


;; alternative way to start OzServer in a shell (alternatively, first run start-oz-server and a bit later then run connect-to-oz)
;; 
;; does not work on SBCL, why??
(start-oz-server :oz-server " ~/.oz/1.3.2/bin/OzServer" :port 5010) 
(connect-to-oz :port 5010)
|#


;; start oz on shell, e.g.
; ~/.oz/1.3.2/bin/OzServer --port=5001 --file=~/.ozrc --resultFormat=lisp

;; establish connection
(connect-to-oz :port 5001) ; (PORT:OPEN-SOCKET "localhost" 5010 NIL)] not implemented for SBCL [1.0.1] 
;; -> seems to require package: db-sockets or net.sbcl.sockets

;; test 
(+ (feed-expression "1 + 3") 
   2)
; -> 6

;; see file ./general-test.lisp for further tests

;; quit 
(quit-oz)


