(in-package :oz)

(feed-statement "{Browse 'it works!!'}")

(+ (feed-expression "1 + 3") 
   2)
; -> 6

(feed-expression "unit(x:a y:[1 2 3])")

(browse-expression "'hi there'")

;; feed Strasheela example code (fix path according to your system)
(feed-file "/Users/t/oz/music/Strasheela/strasheela/examples/01-AllIntervalSeries.oz")

;; call a proc defined in the file fed before
(feed-expression "{SearchOne proc {$ Sol}
			   Xs Dxs in
			   Sol = series(pitches:Xs intervals:Dxs)
			   {AllIntervalSeries 12 Dxs Xs}
		  end}")

;; create some arbitrary Lisp program on the Oz side..
(feed-expression "[mapcar [function [lambda [x] ['*' x x]]] [quote [1 2 3 4]]]")

(eval 
 (feed-expression "[mapcar [function [lambda [x] ['*' x x]]] [quote [1 2 3 4]]]"))


;; Generating Lisp syntax at the Oz side works too: 
;;
;; Here the Lisp form is expressed as a virtual string in Oz (2 strings appended by an #). A virtual string is passed as is by the syntax transformation process (i.e. Strasheelas Out.ozToLisp). A plain string, on the other hand, would have been transformed into a list of integers (thats what an Oz string is) -- except when the OzServer arg --resultFormat=lispWithStrings is used.
(eval 
 (feed-expression "\"(mapcar #'(lambda (x) (* x x)) '(1 2 3 4))\"#\"\""))


(quit-oz)


