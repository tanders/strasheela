;; this is work in progress...

(in-package :cl-user)

(defun transform (x clauses)
  "Transforms x according clauses. Clauses is a list of two element lists containing two functions: a unary test function and a binary transformation function. The first transformation function -- whose test returns true for x -- is called with x and the clauses."
  (funcall (second (find-if #'(lambda (pair)
				(funcall (first pair) x))
			    clauses))
	 x clauses))

#| ;; test
(transform 1 (list (list #'evenp #'(lambda (x clauses) 'even))
		   (list #'oddp #'(lambda (x clauses) 'odd))))
; LISP-TO-OZ::ODD

(transform '(1 (2 3) 4)
	   (list (list #'listp #'(lambda (x clauses)
				   (cons "a list"
					 (mapcar #'(lambda (x)
						     (transform x clauses))
						 x))))
		 (list #'evenp #'(lambda (x clauses) 'even))
		 (list #'oddp #'(lambda (x clauses) 'odd))))
; ("a list" LISP-TO-OZ::ODD ("a list" LISP-TO-OZ::EVEN LISP-TO-OZ::ODD) LISP-TO-OZ::EVEN)
|#

;; some substitute of Oz VSs: represent string by list
(defun list-to-string (xs &optional (seperator " "))
  "Expects a (flat) list containing literal values such as symbols, strings and numbers and outputs a corresponding string where list elements are seperated by whitespace (symbols are expressed by case letters only, cases in strings are preserved)."
  ;; long numbers may be problematic..
  (format nil "~{~A~}"
	  (util:mappend #'(lambda (x)
			    (list
			     ;; transfer symbols to lower case strings
			     ;; but leave strings untouched.
			     (if (stringp x)
				 x
			       (format nil "~(~A~)" x))
			     seperator))
			xs)))

#| ;; test
(list-to-string (list 'test "blauMilch" 1 pi 3.5))
; "test blauMilch 1 3.141592653589793d0 3.5 "

(list-to-string (list 'test "blauMilch" 1 pi 3.5) "")
; "testblauMilch13.141592653589793d03.5"
|#

;; NB: function name should be list-to-oz-record, and there are no spaces needed around parentheses..
(defmethod list-to-oz-tuple ((xs cons))
  (list-to-string 
   (append (list (list-to-string (list (first xs) "(") ""))
	   (rest xs)
	   '(")"))))

#| ;; testing
(list-to-oz-tuple '(note "startTime:" 1.0 "duration:" 1))
; "note( startTime: 1.0 duration: 1 ) "
|#


(defmethod list-to-oz-list ((xs cons))
  "Transforms a list into an Oz list string"
  (list-to-string (append '("[") xs '("]"))))
(defmethod list-to-oz-list ((xs (eql nil)))
  "Transforms a list into an Oz list string"
  "nil")

(defmethod add-newline ((x string))
  (format nil "~A~A" x #\Newline))

(defmethod symbol-to-oz-atom ((x symbol))
  (format nil "'~A'" x))
(defmethod symbol-to-oz-atom ((x string))
  (format nil "'~A'" x))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
;; make sure CM is loaded..
(if (find-package :cm)
    
    (progn
      
      (in-package :cm)

      ;; no buildin CM type checking?
      (defmethod seq? ((x t)) nil)
      (defmethod seq? ((x seq)) t)

      (defmethod seq-to-strasheela ((x seq) clauses)
	(cl-user::add-newline
	 (cl-user::list-to-oz-tuple
	  (list 'sim
		"info:" (if (object-name x)
			    (cl-user::symbol-to-oz-atom (object-name x))
			  "'CM seq'")
		#\Newline
		"items:" (cl-user::list-to-oz-list
			  (mapcar #'(lambda (x) (cl-user::transform x clauses))
				  (subobjects x)))
		#\Newline
		"startTime:" (round (sv x :time))))))


      (defmethod midi? ((x t)) nil)
      (defmethod midi? ((x midi)) t)

      ;; ?? channel?
      (defmethod midi-to-strasheela ((x midi) ignore)
	(cl-user::add-newline
	 (cl-user::list-to-oz-tuple
	  (list 'note
		"startTime:" (round (sv x :time))
		"duration:" (round (sv x :duration))
		"pitch:" (round (sv x :keynum))
		"amplitude:" (round (sv x :amplitude))
		))))

      (defmethod make-strasheela-score ((x seq))
	(cl-user::transform
	 x
	 (list (list #'seq? #'seq-to-strasheela)
	       (list #'midi? #'midi-to-strasheela)
	       ;; default clause: print warning
	       (list #'(lambda (ignore) T)
		     #'(lambda (x ignore)
			 (warn "make-strasheela-score can't handle ~x, skipped" x)
			 "") ))))
      )

  (warn "*** THE COMMON MUSIC PACKAGE IS NOT FOUND! ***"))

|#

#| ;

(midi-to-strasheela #i(midi time 32 keynum 60) nil)

"note( startTime: 32 duration: 0 pitch: 60 amplitude: 64 )  
 "


(make-strasheela-score 
 (new seq :name 'my-test
      :subobjects (loop for i below 10
			collect (new midi :time i))))


(make-strasheela-score 
 (new seq :time 3.0
     :subobjects (loop for i below 10
		       collect (new midi :time i))))


;; import midi file and output Strasheela score
(defparameter x
  (import-events "/Users/t/Sound/tmp/myMicrotonalTest3.midi"))

(subobjects x)

(make-strasheela-score x)

|#

