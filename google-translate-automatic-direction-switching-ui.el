;;; google-translate-automatic-direction-switching-ui.el --- Automatic Direction Switching UI for Google Translate -*- lexical-binding: t; -*-

;; Copyright (C) 2019  nilninull

;; Author: nilninull <nilninull@gmail.com>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; I read various languages, but the writing language is limited to
;; one language.  Mainly when writing something like this sentence in
;; English.

;; For similar people, I have created a mechanism to automatically
;; switch languages.

;; In the past, character codes could be used for this purpose, but
;; now unicode has become popular, so it can not be done.

;; Therefore, I came up with a method of using Emacs's charactorsets
;; to determine the input language.

;; This practice may not work for some language combinations.

;;; Usage:

;; First, please set charactorsets used for the language you want
;; translated to the `google-translate-first-language-charsets'
;; variable.

;; Emacs's character sets can be seen with the function
;; `list-character-sets' or the variable `charset-list'.

;; Next, please specify the language of your main translation
;; destination to the variable `google-translate-second-language'.

;; The variable's value is only used when the function
;; `google-translate-read-args' returns "auto".

;; Finally, use these two functions to translate.
;; `google-translate-at-point-automatic-direction-switching'
;; `google-translate-query-translate-automatic-direction-switching'

;;; Code:

(require 'google-translate)

(defgroup google-translate-automatic-direction-switching-ui nil
  "Automatic Direction Switching UI interface to the Google Translate package."
  :group 'google-translate-core-ui
  :group 'google-translate-manzyuk-ui
  :prefix "google-translate-")

(defcustom google-translate-first-language-charsets nil
  "Please set your first language charasets from Emacs supported charsets.

You can see all charsets from function `list-character-sets' or variable `charset-list'"
  :type '(repeat symbol)
  :group 'google-translate-automatic-direction-switching-ui)

(defun google-translate-first-language-p (str)
  "Check STR charsets are included in `google-translate-first-language-charsets' list."
  (seq-intersection
   (find-charset-string str)
   google-translate-first-language-charsets
   #'eq))

(defcustom google-translate-second-language "en"
  "Please set the second language to use.

Return this value from function `google-translate-read-args',
  when reverse direction is enabled and variable
  `google-translate-default-source-language' is \"auto\" (Detect
  language) ."
  :type 'string
  :group 'google-translate-automatic-direction-switching-ui)

(define-advice google-translate-read-args (:filter-return (langs))
  (cl-destructuring-bind (from-lang to-lang) langs
    (list from-lang (if (string= "auto" to-lang)
                        google-translate-second-language
                      to-lang))))

;;;###autoload
(defun google-translate-at-point-automatic-direction-switching (&optional override-p)
  "Translate the word at point or the words in the active region.

When with command `universal-argument' (OVERRIDE-P is not nil),
query the source and target languages."
  (interactive "P")
  (let* ((words (if (use-region-p)
                    (buffer-substring-no-properties (region-beginning) (region-end))
                  (or (thing-at-point 'word t)
                      (error "No word at point"))))
         (reverse-p (google-translate-first-language-p words))
         (langs (google-translate-read-args override-p reverse-p)))
    (apply #'google-translate-translate `(,@langs ,words))))

;;;###autoload
(defun google-translate-query-translate-automatic-direction-switching (&optional override-p)
  "Interactively translate text with Google Translate.

When with command `universal-argument' (OVERRIDE-P is not nil),
query the source and target languages."
  (interactive "P")
  (let* ((words (read-string "Translate: "))
         (reverse-p (google-translate-first-language-p words))
         (langs (google-translate-read-args override-p reverse-p)))
    (apply #'google-translate-translate `(,@langs ,words))))

(provide 'google-translate-automatic-direction-switching-ui)
;;; google-translate-automatic-direction-switching-ui.el ends here
