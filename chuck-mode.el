;;; chuck-mode.el --- Major mode for editing ChucK code

;; Copyright (C) 2016 Vasilij Schneidermann <v.schneidermann@gmail.com>

;; Author: Vasilij Schneidermann <v.schneidermann@gmail.com>
;; URL: https://github.com/wasamasa/chuck-mode
;; Version: 0.0.1
;; Keywords: languages

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; A major mode for the ChucK audio programming language
;; <http://chuck.cs.princeton.edu/>.

;; See the README for more info:
;; https://github.com/wasamasa/chuck-mode

;;; Code:

(require 'cc-mode)

(eval-when-compile
  (require 'cc-langs)
  (require 'cc-fonts))

(eval-and-compile
  (c-add-language 'chuck-mode 'java-mode))

;;; syntax-table magicks

(declare-function c-populate-syntax-table "cc-langs.el" (table))

(defvar chuck-mode-syntax-table
  (let ((table (funcall (c-lang-const c-make-mode-syntax-table chuck))))
    (modify-syntax-entry ?@ "." table)
    (modify-syntax-entry ?$ "." table)
    table))

;;; language constants

(c-lang-defconst c-symbol-chars
  chuck (concat c-alnum "_"))

(c-lang-defconst c-identifier-ops
  chuck '((left-assoc ".")
          (right-assoc "::")))

(c-lang-defconst c-opt-cpp-symbol
  chuck nil)

(c-lang-defconst c-assignment-operators
  chuck '("=>" "@=>" "<=" "=^" "=<"
          "+=>" "-=>" "*=>" "/=>" "%=>"
          "!=>" "&=>" "|=>" "^=>"
          ">>=>" "<<=>"))

(c-lang-defconst c-primitive-type-kwds
  chuck '("int" "float" "time" "dur" "void"
          ;; more obscure stuff
          "array" "polar" "complex"
          ;; not actually primitives
          "string" "Object" "Event" "UGen"))

(c-lang-defconst c-class-decl-kwds
  chuck '("class"))

(c-lang-defconst c-typeless-decl-kwds
  chuck '("fun" "const"))

(c-lang-defconst c-modifier-kwds
  chuck '("public" "static"))

(c-lang-defconst c-postfix-decl-spec-kwds
  chuck '("extends"))

(c-lang-defconst c-block-stmt-1-kwds
  chuck '("else"))

(c-lang-defconst c-block-stmt-2-kwds
  chuck '("for" "if" "while"))

(c-lang-defconst c-simple-stmt-kwds
  chuck '("break" "continue" "return"))

(c-lang-defconst c-case-kwds
  chuck nil)

(c-lang-defconst c-constant-kwds
  chuck '("null" "true" "false"
          "now" "me" "pi"
          "dac" "adc" "blackhole"
          ;; not really constants...
          "samp" "ms" "second" "minute" "hour" "day" "week"))

;;; font-locking voodoo

(defconst chuck-font-lock-keywords-1 (c-lang-const c-matchers-1 chuck))

(defconst chuck-font-lock-keywords-2 (c-lang-const c-matchers-2 chuck))

(defconst chuck-font-lock-keywords-3 (c-lang-const c-matchers-3 chuck))

;;; indentation style

(c-add-style
 "chuck"
 '("bsd" ; aka allman style
   (c-basic-offset . 4)))

;;; imenu support

(defvar chuck-imenu-class-re
  (rx bol (* whitespace)
      (? "public" (* whitespace))
      "class" (* whitespace)
      (group (+ (any alphanumeric "_"))) (* whitespace)
      (? "extends" (* whitespace)
         (+ (any alphanumeric "_")))))

(defvar chuck-imenu-function-re
  (rx bol (* whitespace)
      "fun" (* whitespace)
      (? "static" (* whitespace))
      (+ (any alphanumeric "_")) (* whitespace)
      (group (+ (any alphanumeric "_")))))

(defvar chuck-imenu-generic-expression
  `(("Classes" ,chuck-imenu-class-re 1)
    ("Functions" ,chuck-imenu-function-re 1)))

;;;###autoload
(define-derived-mode chuck-mode prog-mode "ChucK"
  "Major mode for editing ChucK code."
  ;; add imenu for class/fun lines
  (c-initialize-cc-mode t)
  (c-init-language-vars chuck-mode)
  (c-common-init 'chuck-mode)

  ;; HACK there doesn't appear to be a better way of doing this
  ;; without interfering with user customizations...
  (unless (or c-file-style
              (stringp c-default-style)
              (assq 'chuck-mode c-default-style))
    (c-set-style "chuck"))

  (c-run-mode-hooks 'c-mode-common-hook 'chuck-mode-hook)
  (cc-imenu-init chuck-imenu-generic-expression)
  (c-update-modeline))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ck\\'" . chuck-mode))

(provide 'chuck-mode)
;;; chuck-mode.el ends here
