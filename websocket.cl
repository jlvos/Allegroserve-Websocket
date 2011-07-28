(in-package :net.aserve.websocket)

(defparameter *response-websocket-handshake* (net.aserve::make-resp 101 "Switching Protocols"))
(defparameter *websocket-clients nil)
(defparameter *websocket-guid* "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")

(defun websocket-function (req ent)
  (setf test (request-raw-request req))
  (if (and (header-slot-value req :connection) (header-slot-value req :upgrade))
      (progn
	(setf (reply-header-slot-value req :connection) "Upgrade")
	(with-http-response (req ent :response *response-websocket-handshake*)
	  (with-http-body (req ent :headers (websocket-08-handshake-header req)))))
    (progn
      (setf (reply-header-slot-value req :connection) "Upgrade")
      (with-http-response (req ent)
	(with-http-body (req ent :headers (websocket-08-handshake-header req)))))
     ))

(defun websocket-08-handshake-header (request &optional protocol)	
  (let ((key (header-slot-value request :sec-websocket-key))
	(header))
    
    (push (cons :Upgrade "WebSocket") header)
    (push (cons :connection "Upgrade") header)
    (push (cons :Sec-WebSocket-Accept (excl:integer-to-base64-string (excl:sha1-string (concatenate 'string key *websocket-guid*)))) header)
    (if protocol (push (cons :Sec-WebSocket-Protocol protocol) header))
    header))
    
  
	
	
		  
(defun websocket-76-handshake-header (request)
  (let ((origin (header-slot-value request :origin))
	(host (header-slot-value request :host))
	(key1 (header-slot-value request :sec-websocket-key1))
	(key2 (header-slot-value request :sec-websocket-key2))
	(header))
    (if origin (push (cons :Sec-WebSocket-Origin origin) header))
    (if host (push (cons :Sec-WebSocket-Location host) header))))
    

(defun generate-76-accept-key (key1 key2 key3)
  (let ((key1-number (parse-integer (remove-if #'(lambda (x) (not (digit-char-p x))) key1)))
	(key1-spaces-count (count #\Space key1))
	(key2-number (parse-integer (remove-if #'(lambda (x) (not (digit-char-p x))) key2)))
	(key2-spaces-count (count #\Space key2)))
    
    (excl:md5-string (concatenate 'string  (write-to-string (/ key1-number key1-spaces-count)) (write-to-string (/ key2-number key2-spaces-count)) key3))))
	
