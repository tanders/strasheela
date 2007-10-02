
;; !! OZDIR is installation dependend
; (setq load-path (cons "/usr/lib/mozart/share/elisp/" load-path))
(setq load-path (cons "/usr/local/oz/share/elisp" load-path))
(require 'oz)

(defun ozindent (file) 
  (find-file file) 
  (oz-mode) 
  (oz-indent-buffer) 
  (save-buffer) 
  (kill-emacs))
