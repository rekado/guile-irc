;; Copyright (C) 2012 bas smit (fbs)
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

(define-module (irc handlers)
  #:version (0 1)
  #:use-module (irc irc)
  #:use-module ((irc message)
		 #:renamer (symbol-prefix-proc 'msg:))
  #:export (install-ping-handler!
	    install-printer!
	    install-hello-handler!
	    install-eof-handler!
	    remove-eof-handler!
	    remove-printer!
	    remove-ping-handler!
	    remove-hello-handler!))

(define (install-ping-handler! obj)
  (let ([ping-handler
	 (lambda (msg)
	   (do-command obj "PONG" (string-append
				   ":"
				   (msg:middle (msg:parameters msg)))))])
    (add-simple-message-hook! obj ping-handler #:tag 'ping #:command 'PING)))


(define* (install-printer! obj  #:key verbose (port (current-output-port)))
  (let ([printer
	 (if verbose
	     (lambda (msg)
	       (format port "raw: ~a\nprefix: ~a\ncommand: ~a\nparameters: ~a\n"
		       (msg:raw msg) (msg:prefix msg) (msg:command msg) 
		       (msg:parameters msg))
	       msg)
	     (lambda (msg)
	       (format port "~a\n" (msg:raw msg))
	       msg))])
    (add-message-hook! obj printer #:tag 'printer)))

(define* (install-hello-handler! obj #:key (prefix ",") (command "hello") 
				 (reply "hello master!"))
  (let ([handler
	 (lambda (msg)
	   (let ([body (msg:trailing (msg:parameters msg))]
		 [key (string-append prefix command)])
	     (if (and body 
		      (string=? (car (string-split body #\ )) key))
		 (do-privmsg obj (parse-target obj msg) reply))))])
    (add-simple-message-hook! obj handler #:command 'PRIVMSG #:tag 'hello)))

;; (define (install-eof-handler! obj)
;;   (set-eof-handler! obj do-close))

;; (define (remove-eof-handler! obj)
;;   (reset-eof-handler! obj))

(define (remove-hello-handler! obj)
  (remove-message-hook! obj 'hello))

(define (remove-printer! obj)
  (remove-message-hook! obj 'printer))

(define (remove-ping-handler! obj)
  (remove-message-hook! obj 'ping))
