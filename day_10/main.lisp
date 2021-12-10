(ql:quickload :cl-ppcre)

(defun get-nums ()
  (with-open-file (stream "input")
    (loop :for line = (read-line stream nil)
	  :while line
	  :collect (coerce line 'list))))

(defun is-open (c)
  (or (char= c #\()
      (char= c #\{)
      (char= c #\[)
      (char= c #\<)))

(defun closes (c)
  (cond ((char= c #\() #\))
	((char= c #\{) #\})
	((char= c #\[) #\])
	((char= c #\<) #\>)))

(defun parta ()
  (labels ((cost (c)
	     (cond ((char= c #\)) 3)
		   ((char= c #\]) 57)
		   ((char= c #\}) 1197)
		   ((char= c #\>) 25137)))
	   (process (str stk)
	     (if str
		 (if (is-open (car str))
		     (process (cdr str) (cons (car str) stk))
		     (if (char= (closes (car stk)) (car str))
			 (process (cdr str) (cdr stk))
			 (cost (car str))))
		 0)))
    (let ((strs (get-nums)))
      (loop :for lst in strs
	    :sum (process lst nil)))))

(defun partb ()
  (labels ((cost (c)
	     (cond ((char= c #\)) 1)
		   ((char= c #\]) 2)
		   ((char= c #\}) 3)
		   ((char= c #\>) 4)))
	   (malformed (str stk)
	     (if str
		 (if (is-open (car str))
		     (malformed (cdr str) (cons (car str) stk))
		     (if (char= (closes (car stk)) (car str))
			 (malformed (cdr str) (cdr stk))
			 nil))
		 stk))
	   (get-score (stk)
	     (reduce (lambda (acc c) (+ (* 5 acc) (cost (closes c)))) stk :initial-value 0)))
    (let* ((strs (remove-if-not (lambda (x) (malformed x nil)) (get-nums)))
	   (lst (sort (loop :for lst in strs
			    :collect (get-score (malformed lst nil))) '<)))
      (nth (floor (/ (length lst) 2)) lst))))
