(in-package net.aserve.websocket)

(defclass frame ()
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
