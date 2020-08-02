#!/bin/sh

/usr/local/bin/emacs -Q --batch --eval "
(progn
  (require 'server)
  (princ
   (condition-case nil
       (server-eval-at
        \"server\"
        '(if (org-clocking-p)
             (let* ((len 50)
                    (ellipsis \"...\")
                    (currently-clocked-duration
                     (org-duration-from-minutes
                      (floor (org-time-convert-to-integer (org-time-since org-clock-start-time)) 60)))
                    (s (format \"[%s]%s\" currently-clocked-duration org-clock-heading)))
               (format \":alarm_clock:%s\"
                       (if (> (length s) len)
                           (format \"%s%s\" (substring s 0 (- len (length ellipsis))) ellipsis)
                         s)))
           \":coffee:\"))
     (error \":bangbang:\n---\nEmacs is not running.\"))))"
