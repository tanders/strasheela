(in-package :oz)

;;
;; TODO
;;
;; * Test Strasheela Score to CM .. 
;;
;; * Test Strasheela Score to ENP .. 
;;
;; * Integrating the functionality defined here into PWGL
;;
;; * ?? Value transformation: LispToOz (cf. Out.ozToLisp)
;;
;; * ?? define mini language which maps (subset of) Oz to Lisp. I can then write Oz code using Lisp syntax, which is backstage transformed and feed to Oz..
;;
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Using port package from CLOCC
;;
;; http://cl-cookbook.sourceforge.net/sockets.html: The socket functions provided by PORT currently work without modifications on a wide range of Common Lisp implementations (Allegro, Lispworks, CLISP, CMU CL, SBCL, GCL).

(defparameter *default-oz-server* "~/.oz/1.4.0/bin/OzServer")
; (defparameter *default-oz-server* "OzServer")
(defparameter *default-oz-init-file* "~/.ozrc")


(let ((my-port 5000))
  (defun run-oz (&key (oz-server *default-oz-server*)
                      port
                      (file *default-oz-init-file*)
                      (result-format "lisp"))
    "Easy to use top-level command to start the OzServer and connect Lisp to it. oz-server is the OzServer application to call (a string). See the OzServer documentation for the meaning of the other arguments. Meanigful values for result-format are \"lisp\" and \"lispWithStrings\"."
    (if port 
        (setf my-port port) ; take given port number
      (incf my-port)) ; otherwise ensure fresh port number
    ;; start-oz-server runs concurrently in its own thread
    (port:make-process (format nil "OzServer at port ~a" my-port)
                       #'start-oz-server :oz-server oz-server
                       :port my-port
                       :file file
                       :result-format result-format)
    ;; wait for 5 secs to make sure server is started
    (sleep 5)
    (connect-to-oz :port my-port
                   :host "localhost")))

;;;;;

(defun start-oz-server (&key (oz-server *default-oz-server*)
                             port
                             (file *default-oz-init-file*)
                             ;; either "lisp" or "lispWithStrings"
                             (result-format "lisp"))
  "Starts the OzServer application in its own shell. oz-server is the OzServer application to call (a string). See the OzServer documentation for the meaning of the other arguments. Meanigful values for result-format are \"lisp\" and \"lispWithStrings\"."
  (bash oz-server 
         :args (list (arg-string "--port=" port)
                     (arg-string "--file=" file)
                     (arg-string "--resultFormat=" result-format))
         :gui? T))
;;
;; aux def
(defun arg-string (argname value)
  "[Aux def] Returns a string \"argname value\". However, if value is nil then nil is returned."
  (format nil "~{~A~}" (if value 
                           (list argname value)
                         nil)))
; (arg-string "--port=" 50000)
; (arg-string "--port=" nil)



;; The function shell is very general, but a copy is kept in oz-server-lisp-client anyway in order to aviod complex dependencies of this package..
(defun bash (cmd &key args (gui? nil) (init-file "~/.bash_profile"))
  "A portable implementation for calling the bash shell. Executes cmd with args and shows the output. If gui? is nil (the default), then the output is written to *standard-output*. Otherwise, the output is written into a special window (presently, this is only supported for LispWorks where a CAPI pane is opened). 
NB: this function does not return before the cmd is finished -- consider running it is its own thread (e.g. using port:make-process)."
  (let* ((out-stream (if gui?
                        #+lispworks (capi:collector-pane-stream 
                                     (capi:contain (make-instance 'capi:collector-pane 
                                                                  :title "Shell output")))
                        #-lispworks T
                      T))
	 ;; In contrast to SBCL on Linux, lispworks on MacOS does not load all bash init files (why?) -- so I do it by hand... 
         (my-command (format nil "\"~a~a~{ ~a~}\"" 
                             ;; init file
                             (if init-file 
                                 (format nil ". ~a; " init-file)
                               "")
                             ;; command
                             cmd args))
;        (my-command (format nil "\"~a~{ ~a~}\"" 
;                           ;; command
;                            cmd args))
        my-pipe)
    ;;
    ;; call programm
    ;;

;;     ;; first some old and unused stuff, kept here just in case...
;;
;;     ;; SBCL requires a workaround, because sb-ext:run-program (which
;;     ;; is called by port:pipe-input) expects a program which it can
;;     ;; find in the file system (e.g. no script is permitted). However,
;;     ;; I need to feed the shell the usual init files (which causes
;;     ;; my-command to be a small shell script). So, my-command is first
;;     ;; written to tmp-file-path, tmp-file-path is made executable and
;;     ;; then called.
;;     #+SBCL
;;     (let* ((i 1) (tmp-dir "/tmp/")
;; 	   ;; multiple calls from the same running Lisp result in
;; 	   ;; multiple independent server scripts, but when restarting
;; 	   ;; Lisp then these scripts are overwritten
;; 	   (tmp-file-path (format nil "~AStartOzServer-~A.sh" tmp-dir (incf i))))         
;;       (format out-stream ";; $ echo '~A' > ~A ~%" my-command tmp-file-path)
;;       (with-open-file (my-stream tmp-file-path
;; 				 :direction :output
;; 				 :if-exists :supersede)
;; 	(format my-stream "~A" my-command))
;;       ;; make tmp-file-path executable      
;;       (format out-stream ";; $ /bin/chmod +x ~A~%" tmp-file-path)
;;       (port:run-prog "/bin/chmod" :args (list "+x" tmp-file-path))
;;       (format out-stream ";; $ ~a~%" tmp-file-path)
;;       (setf my-pipe (port:pipe-input tmp-file-path)))
    
;;     #-SBCL ;; tested for LispWorks
;;     (progn 
;;       (format out-stream ";; $ ~a~%" my-command)
;;       (setf my-pipe (port:pipe-input my-command)))


    ;; bash -c reads all profile/rc files, but only on linux..
    ;; my-command can not read directly, because (i) I need to have the full environment and (ii) SBCL requires a program which it can find in the file system (e.g. no script is permitted in order to load init files). /bin/bash is such a program..
    (format out-stream ";; $ /bin/bash -c ~a~%" my-command)
    (setf my-pipe (port:pipe-input "/bin/bash" "-c" my-command))

    ;;
    ;; write program output
    ;;
    (loop
     (let ((line (read-line my-pipe nil nil)))
       (unless line (return))
       (format out-stream "~a~%" line)))
    ))

; (bash "ls" :args (list "-l" "~"))
;; NB: the PATH is not properly printed (compare with output from env), why?
; (bash "echo" :args (list "$PATH"))
; (bash "env")


;;;;;;;;;;;

#+sbcl
(require 'sb-bsd-sockets)
;; see http://paste.lisp.org/system-server/show/sb-bsd-sockets-tests/tests

(let (oz-socket-stream)

  (defun connect-to-oz (&key (host "localhost") port)
    "Connects to the OzServer application on given host (a string with the host name) at given port (an integer)."
    #-sbcl ;; e.g. lispworks
    (setf oz-socket-stream (port:open-socket host port))    
    ;; !! for now implementation dependent, later put SBCL specifica
    ;; into port.lisp
    #+sbcl
    (let ((my-socket (make-instance 'sb-bsd-sockets:inet-socket 
				    :type :stream 
				    :protocol :tcp))
	  (host-addr (first (sb-bsd-sockets:host-ent-addresses 
			     (sb-bsd-sockets:get-host-by-name host)))))
      ; (sb-bsd-sockets:non-blocking-mode my-socket)
      (sb-bsd-sockets:socket-connect my-socket host-addr port) 
      (setf oz-socket-stream 
	    (sb-bsd-sockets:socket-make-stream my-socket
					       :input t 
					       :output t 
					       ; :buffering :none
					       )))
    )
  
;  (defun check-socket ()
;    )

  ;; Hm: I could ensure that the socket is always closed cleanly after processing with unwind-protect, but I don't want to loose time opening and closing the port all the time..
  (defun feed-to-oz (directive code-string)
    "Feeds code to the OzServer which is preceeded by %! <directive>. See OzServer documentation for details on supported directives."
;   (check-socket)
    (progn 
      (format oz-socket-stream (format nil "%!~A~%~A" directive code-string))
      (force-output oz-socket-stream)))

  ;; NB: order of results is thread-save on Oz side, but not yet on Lisp side (no concurrency standard for Lisp..)
  (defun read-from-oz ()
    "Reads a lisp expression from a result returned by the Oz server."
;   (check-socket)
    (read oz-socket-stream))

  (defun disconnect-oz ()
    "Closes the socket connection with the OzServer."
    (close oz-socket-stream))
)


(defun feed-file (path)
  "Feeds the file path (a string) to the OzServer."
  (feed-to-oz "file" path))

(defun feed-statement (code-string)
  "Feeds the statement code-string (a string) to the OzServer."
  (feed-to-oz "statement" code-string))

(defun feed-expression (code-string)
  "Feeds the expression code-string (a string) to the OzServer and returns the result of the expression as Lisp value (the suitable result-format must be set when starting the OzServer)."
  (progn 
    (feed-to-oz "expression" code-string)
    (read-from-oz)))
  
(defun browse-expression (code-string)
  "Feeds the expression code-string (a string) to the OzServer and displays the result with the Oz Browser."
  (feed-to-oz "browse" code-string))
  "Feeds the expression code-string (a string) to the OzServer and displays the result with the Oz Inspector."
(defun inspect-expression (code-string)
  (feed-to-oz "inspect" code-string))


(defun quit-oz ()
  "Quits the OzServer (and implicitly closes the connections)."
  (feed-to-oz "quit" ""))

