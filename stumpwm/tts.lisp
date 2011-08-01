;;; tts.lisp -- Common Lisp interface  to Emacspeak speech servers
;;; $Id: tts.lisp 7078 2011-06-29 22:07:46Z tv.raman.tv $
;;; $Author: tv.raman.tv $
;;; Description:   Interface Common Lisp (SBCL)  to Emacspeak TTS servers
;;; Keywords: Sawfish, Emacspeak, Audio Desktop
;;; {  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2011-06-29 15:07:46 -0700 (Wed, 29 Jun 2011) $ |
;;;  $Revision: 7078 $ |
;;; Location undetermined
;;;

;;; }
;;; {  Copyright:

;;; Copyright (C)  2011, T. V. Raman<raman@cs.cornell.edu>
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; }
;;; { Introduction:

;;; Commentary:
;;; Interface Common  Lisp  to Emacspeak TTS servers

;;; }
(in-package :stumpwm)
;;; { Settings

(defvar *emacspeak* "/home/raman/emacs/lisp/emacspeak/"
  "Root of Emacspeak installation.")

(defvar *tts-process* nil
  "Handle to tts server connection.")

(defvar *tts-dtk*
  (concatenate 'string   *emacspeak* "servers/dtk-exp")
  "DTK tcl server")

(defvar *tts-outloud*
  (concatenate 'string   *emacspeak* "servers/outloud")
  "Outloud tcl server")

(defvar *tts-32-outloud*
  (concatenate 'string   *emacspeak* "servers/32-outloud")
  "Outloud tcl server")

(defvar *tts-engine* *tts-dtk*
  "Default TTS  engine. User settable.")

;;; }
;;; {Internal  Functions

(defun tts-open ()
  "Open a TTS session."
  (setq *tts-process*
        (sb-ext:run-program
         *tts-engine* nil :wait nil  :input :stream)))

(defun tts-close ()
  "Close a TTS session."
  (when(and  (sb-ext:process-p *tts-process*)
             (sb-ext:process-alive-p *tts-process*))
    (sb-ext:process-close *tts-process*))
  (setq *tts-process* nil))

(defun tts-running-p ()
  "Is there a tts process up and running?"
  (and *tts-process*
       (sb-ext:process-p *tts-process*)
       (sb-ext:process-alive-p *tts-process*)))

(defvar *tts-stop-immediately* t
  "Stop speech immediately.")
(defun tts-queue (text)
  "Queue text to speak."
  (unless (and  *tts-process*
                (sb-ext:process-alive-p *tts-process*))
    (tts-open))
  (let ((i (sb-ext:process-input *tts-process*)))
    (write-line (format nil "q {~s}" text) i)
    (force-output i)))

(defun tts-force ()
  "Speak all queued text."
  (let ((i (sb-ext:process-input *tts-process*)))
    (write-line "d" i)
    (force-output i)))

;;; }
;;; {Exported Functions

(defun tts-speak (text)
  "Say some text."
  (unless (and  *tts-process*
                (sb-ext:process-alive-p *tts-process*))
    (tts-open))
  (let ((i (sb-ext:process-input *tts-process*)))
    (when *tts-stop-immediately*
      (write-line "s"  i)
      (force-output i))
    (write-line (format nil "q ~s\;d" text) i)
    (force-output i)))

(defun tts-say (text)
  "Say some text."
  (unless (and  *tts-process*
                (sb-ext:process-alive-p *tts-process*))
    (tts-open))
  (let ((i (sb-ext:process-input *tts-process*)))
    (when *tts-stop-immediately*
      (write-line "s"  i)
      (force-output i))
    (write-line (format nil "tts_say  ~s" text) i)
    (force-output i)))

(defun tts-speak-list (lines)
  "Speak an arbitrary number of lines."
  (mapc 'tts-queue lines)
  (tts-force))

(defun tts-letter (text)
  "Speak letter."
  (unless (and  *tts-process*
                (sb-ext:process-alive-p *tts-process*))
    (tts-open))
  (let ((i (sb-ext:process-input *tts-process*)))
    (write-line (format nil "l ~s" text) i)
    (force-output i)))

;;; }
(provide 'tts)

;;; { end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;; }
