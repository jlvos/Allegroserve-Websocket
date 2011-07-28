(in-package net.aserve.websocket)

(defclass frame ()
<<<<<<< HEAD
  ((final-frame? :initarg :final-frame?
		 :accessor frame-final-frame?)
   (type :initarg :type
	 :accessor frame-type)
   (payload-length :initarg :payload-length
		   :accessor frame-payload-length)
   (payload :initarg :payload
	    :accessor frame-payload)))

(defstruct websocket-error 
  (code :type integer)
  (message :type string))
	   

(defun create-close-error-frame (error)
  (let* ((error-code (websocket-error-code error))
	 (error-message (websocket-error-message error))
	 (payload (concatenate 'vector (vector (logand  error-code  #xff) (ash error-code -8) ) (excl:string-to-octets error-message :external-format :utf8))))
    (make-frame :close payload t)))

(defun make-frame (type payload &optional (final t)) 
  (make-instance 'frame 
    :final-frame? final
    :type type
    :payload payload
    :payload-length (array-dimension payload 0)))
    

(defun read-08-frame (socket)
  (let* (fin rsv opcode masked payload-length masking-key payload-data byte)
    ;;read the first byte and set the corresponding values
    (setf byte (read-byte socket))
    
    (setf fin (ash (logand byte #b10000000) -7))
    (setf rsv (ash (logand byte #b01110000) -4))
    (setf opcode (logand byte #b00001111))
    
    ;;read the second byte and set the corressponding values
    (setf byte (read-byte socket))
    
    (setf masked (ash (logand byte #b10000000) -7))
    (setf payload-length (logand byte #b0111111))
    ;; if the payload length did not fit in the single byte
    (if (= payload-length 126) (setf payload-length (excl::octets-to-integer #((read-byte socket) (read-byte socket)))))
    (if (= payload-length 127) (let ((buf (make-array 8 :element-type '(unsigned-byte 8))))
				 (dotimes (i 8) (setf (aref buf i) (read-byte socket)))
				 (setf payload-length (excl::octets-to-integer buf))))
    ;; if there is a masking key in the frame retrieve it
    (if (> masked 0) (let ((buf (make-array 4 :element-type '(unsigned-byte 8))))
				 (dotimes (i 4) (setf (aref buf i) (read-byte socket)))
				 (setf masking-key (excl::octets-to-integer buf))))
    
    ;;if there is payload available retrieve it
    (if (> payload-length 0) (progn  (setf payload-data(make-array payload-length :element-type '(unsigned-byte 8)))
				     (dotimes (i payload-length) (setf (aref payload-data i) (read-byte socket)))))
    
    ;; 
    (if (= masked 0)
	(make-websocket-error :code 1002 :message "Unmasked Client frame")
      (make-instance 'frame 
	:final-frame? (if (> fin 0) t nil)
	:type (case opcode
		(#x0 :continuation)
		(#x1 :text)
		(#x2 :binary)
		((#x3 #x4 #x5 #x6 #x7) :reserved-frame)
		(#x8 :close)
		(#x9 :ping)
		(#xa :pong)
		((#xb #xc #xd #xe #xf) :reserved-control-frame))
      :payload-length payload-length
      :payload (mask-payload payload-data masking-key)))))

(defun write-08-frame (frame socket)
  (let ((fin (if (frame-final-frame? frame) (ash 1 7) 0))
	(rsv (ash 0 4))
	(opcode	(case (frame-type frame)
		  (:continuation #x0)
		  (:text #x1)
		  (:binary #x2)
		  (:reserved-frame #x3)
		  (:close #x8)
		  (:ping #x9)
		  (:pong #xa)
		  (:reserved-control-frame #xb)
		  (otherwise (return-from write-08-frame nil))))
	(mask (ash 0 7)) ;; Currently always 0
	(frame-payload-lenght-byte  (excl:if* (<= (frame-payload-length frame) #x7d)
					   then (frame-payload-length frame)
					 elseif (<= (frame-payload-length frame) #xffff)
					   then #x7e
				elseif (<= (frame-payload-length frame) #x7fffffffffffffff)
				       then #x7f))
	(frame-payload-extended-bytes (if (< (frame-payload-length frame) 126) nil (frame-payload-length frame)))
	(frame-payload-bytes (frame-payload frame)))
    
    ;;write all the bytes
    (write-byte (logior fin rsv opcode) socket)
    (write-byte (logior mask frame-payload-lenght-byte) socket)
    (write- frame-payload-extended-bytes :stream socket)
    (excl:write-vector frame-payload-bytes socket)))

(defun mask-payload (payload mask)
  (let* ((array-size (array-dimension payload 0))
	 (masked-payload (make-array array-size :initial-element #x00 :element-type '(unsigned-byte 8))))   
    (dotimes (i array-size masked-payload) (setf (aref masked-payload i) (logxor (aref masked-payload i) (aref mask (mod i 4)))))))
=======
  ((raw-frame)
   (type)
   (payload-length)
   (payload-masked?)
   (pay-load-mask)
   (masked-payload)
   (unmasked-payload)
  ))

(defun encode-frame (payload type)

(defun decode-frame (array)
  )
>>>>>>> 95942920df9a45d22c88b61b107ecf905caf8ec8
