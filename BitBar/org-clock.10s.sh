#!/bin/sh

/usr/local/bin/emacs -Q --batch --eval "(progn
(require 'server)
(princ
  (format \"%s\\n\"
    (condition-case nil
      (server-eval-at \"server\"
        '(if (org-clocking-p)
           (let ((len 50)
                 (ellipsis \"...\")
                 (s (format \"[%s]%s\" (org-duration-from-minutes (org-clock-get-clocked-time)) org-clock-heading)))
             (format \":alarm_clock:%s\"
                     (if (> (length s) len)
                         (format \"%s%s\" (substring s 0 (- len (length ellipsis))) ellipsis)
                       s)))
         \":coffee:\"))
      (error \":bangbang:\n---\nEmacs is not running.\")))))"
