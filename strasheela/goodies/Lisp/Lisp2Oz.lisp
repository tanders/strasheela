

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; lisp2oz
;;

#| ; Doc

The method lisp2oz translate a literal Lisp value (possibly nested) into the code for a corresponding Oz value (a string). Conversion of the following Lisp values is supported: integers, floats, ratios (ratios are translated into floats), T, nil (translated into nil or false depending on the value of *Oz-value-of-nil*), symbols, characters, strings and lists. 

In case a list contains any keywords, then it is translated into an Oz record where the Lisp keywords become the record features in Oz. Thus it is important that every Lisp keyword in a list has a corresponding value and that they are all unique (e.g., '(:test 1) is translated into "unit(test:1)" but the result of '(:test) is undefined). The label of a record is optionally specified with the keyword :record-label. This keyword and its value (the actual label) always must be the last to list elements. 

|#


(defmethod lisp2oz ((x t))  
  (error "unsupported value for transformation into Oz: ~A" x))

;; PROBLEM: Lisp nil can mean Oz nil or false. 
(defparameter *Oz-value-of-nil* "nil"
  "The transformation of the Lisp value nil into Oz is ambigious (can be nil or false in Oz). The intended Oz value is set globally via this variable (as Oz string, i.e. \"nil\" or \"false\").")
(defmethod lisp2oz ((x (eql nil)))
  *Oz-value-of-nil*)

(defmethod lisp2oz ((x (eql T)))
  "true")

(defmethod lisp2oz ((x number))  
  (format nil "~A" x))

(defmethod lisp2oz ((x ratio))
  (format nil "~F" x))

(defmethod lisp2oz ((x character))  
  (format nil "~A" x))

(defmethod lisp2oz ((x string))  
  (format nil "\"~A\"" x))


(defmethod lisp2oz ((xs list))
  "Expects a lisp list and returns a corresponding Oz value (a string). This is either an Oz list or an Or record (depending whether xs contains keywords)."
  (if (some #'keywordp xs)
      (keyword-list-to-lisp xs)
      (let ((xs (mapcar #'lisp2oz xs)))
	(format nil "[~A~{ ~A~}]" (first xs) (rest xs)))))


;; traverse list: if some value is a keyword, then it becomes a record feature and the next list value the feature value -- even if it again is a keyword.

;; problem: I cannot have a plain list containing keywords, that may result in an error (e.g. the number of keyword-values may not work out..)

;; tmp external def
(defun aux (xs)
  (if (eq xs nil) 
      nil
      (let ((fst (first xs)))
	(if (keywordp fst)
	    (cons
	     (format nil "~A ~A" (keyword2ozfeature fst) (lisp2oz (second xs)))
	     (aux (rest (rest xs))))
	    (cons (lisp2oz fst) (aux (rest xs)))))))
(defun keyword-list-to-lisp (xs)
  ;; check whether last two list elements are :record-label <label>
  (let* ((lst2 (last xs 2))
	 (has-label? (eq (first lst2) :record-label))
	 (label (if has-label? (second lst2) 'unit))
	 ;; in case, skip label spec (shadow orig xs)
	 (xs (if label? (butlast xs 2) xs)))
    (format nil "~A(~{ ~A~})" (lisp2oz label) 
	    (aux xs))))


(defun keyword2ozfeature (x)
  "Expects a Lisp keyword and returns an Oz record feature with a colon"
  (format nil "~A:" (lisp2oz x)))

(defmethod lisp2oz ((x symbol))
  "Expects a Lisp symbol and returns an Oz atom"
  (format nil "'~A'" x))
  
;; (defmethod lisp2oz ((x symbol))
;;   "Expects a Lisp symbol and returns an Oz symbol (a string). All Oz symbol char are downcase, and every occurance of - is translated into _."
;;  (map 'string #'(lambda (char) 
;; 		 (if (char= char #\-)
;; 		     #\_
;; 		     char)) 
;;       (string-downcase (format nil "'~A'" x))))



#| % some testing

(lisp2oz T)

(lisp2oz '(1 :a 2 :b (3 4 :x 5)))

(lisp2oz '(1 2 3 :record-label bla-bla))

(lisp2oz '(:test 1 :test2))

|#




