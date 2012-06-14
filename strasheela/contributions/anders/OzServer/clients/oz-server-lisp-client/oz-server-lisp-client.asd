;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(unless (find-package :oz-server-lisp-client)
  (make-package :oz-server-lisp-client
                :nicknames '(:oz)
                :use '(:common-lisp)))

(asdf:defsystem oz-server-lisp-client
  :long-description "A lisp-side client for the OzServer, which is part of Strasheela. oz-server-lisp-client allows a Lisp program to execute arbitrary Oz code by calling on the OzServer." 
  :author "Torsten Anders"
  :serial t ;; the dependencies are linear.
  :components ((:file "lisp-client")
	       (:file "export"))
  ;; oz-server-lisp-client depends on port from CLOCC
  ;; (http://clocc.sourceforge.net/). A version of port with an ASDF
  ;; system file is available, e.g., for Debian/Ubuntu as cl-port (see
  ;; http://packages.debian.org/unstable/devel/cl-port). For a
  ;; non-debian system, just get the sources
  ;; (e.g. cl-port_20060408.orig.tar.gz and
  ;; cl-port_20060408-1.diff.gz) and do
  ;; 
  ;; > cd cl-port-20060408.orig
  ;; > patch -p1 < pathTo/cl-port_20060408-1.diff
  :depends-on ("port"))

