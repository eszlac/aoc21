(ql:quickload "cl-ppcre")
(ql:quickload "alexandria")
(use-package :alexandria)

(defun get-nums ()
  (with-open-file (stream "input")
    (let* ((key (coerce (read-line stream nil) 'vector))
	   (lst (progn (read-line stream nil)
		       (loop :for line = (read-line stream nil)
			     :while line
			     :collect line)))
	   (arr (make-array (list (length lst) (length (car lst))) :initial-contents lst)))
      (values key arr))))

(defun to-px (lst key)
  (aref key (parse-integer
	     (coerce (mapcar (lambda (x) (cond ((char= x #\#) #\1)
					       ((char= x #\.) #\0))) lst) 'string)
	     :radix 2)))

(defun 2+ (x)
  (+ x 2))

(defun parta ()
  (multiple-value-bind (key pixels)
      (get-nums)
    (labels ((get-pixel (i j pixels default)
	       (let ((dims (array-dimensions pixels)))
		 (if (and (>= i 0) (>= j 0)
			  (< i (car dims)) (< j (cadr dims)))
		     (aref pixels i j)
		     default)))
	     (get-pixels (x y pixels default)
	       (flatten (loop :for i from (1- x) to (1+ x)
			      :collect (loop :for j from (1- y) to (1+ y)
					     :collect (get-pixel i j pixels default)))))
	     (enhance (img default)
	       (let* ((old-dims (array-dimensions img))
		      (new-arr (make-array (mapcar (lambda (x) (+ x 4)) old-dims))))
		 (loop :for i from -2 to (1+ (car old-dims))
		       :do (loop :for j from -2 to (1+ (cadr old-dims))
				 :do (setf (aref new-arr (2+ i) (2+ j))
					   (to-px (get-pixels i j img default) key))))
		 new-arr)))
      (let* ((res (enhance (enhance pixels #\.) #\#))
	     (dims (array-dimensions res)))
	(loop :for i from 0 below (car dims)
	      :sum (loop :for j from 0 below (cadr dims)
			 :if (char= (aref res i j) #\#)
			   :sum
			   1))))))

(defun partb ()
  (multiple-value-bind (key pixels)
      (get-nums)
    (labels ((get-pixel (i j pixels default)
	       (let ((dims (array-dimensions pixels)))
					;(format t "~d, ~d~%" i j)
		 (if (and (>= i 0) (>= j 0)
			  (< i (car dims)) (< j (cadr dims)))
		     (aref pixels i j)
		     default)))
	     (get-pixels (x y pixels default)
	       (flatten (loop :for i from (1- x) to (1+ x)
			      :collect (loop :for j from (1- y) to (1+ y)
					     :collect (get-pixel i j pixels default)))))
	     (enhance (img default)
	         (let* ((old-dims (array-dimensions img))
		      (new-arr (make-array (mapcar (lambda (x) (+ x 4)) old-dims))))
		 (loop :for i from -2 to (1+ (car old-dims))
		       :do (loop :for j from -2 to (1+ (cadr old-dims))
				 :do (setf (aref new-arr (2+ i) (2+ j))
					   (to-px (get-pixels i j img default) key))))
		 new-arr)))
      (let* ((defs (loop :for i from 1 to 25
			 :append (list #\. #\#)))
	     (res (reduce (lambda (a chr) (enhance a chr)) defs :initial-value pixels))
	     (dims (array-dimensions res)))
	(loop :for i from 0 below (car dims)
	      :sum (loop :for j from 0 below (cadr dims)
			 :if (char= (aref res i j) #\#)
			   :sum
			   1))))))
