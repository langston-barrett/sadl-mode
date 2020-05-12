;;; sadl.el --- A major mode for editing SADL files  -*- lexical-binding: t; -*-

;; Copyright (C) 2020, Langston Barrett

;; Author: Langston Barrett <langston.barrett@gmail.com>
;; Keywords: languages
;; Package-Requires: ((emacs "24.4") (cl-lib "0.5"))
;; Package-Version: 0.1.0
;; Homepage: https://github.com/langston-barrett/sadl-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a major mode for editing SADL files.

;;; Code:

(require 'compile)
(require 'cl-lib)

;;; Configuration

(defgroup sadl '()
  "SADL"
  :group 'languages
  :tag "SADL")

(defface sadl-keyword-face
  '((t (:inherit font-lock-keyword-face)))
  "How to highlight SADL keywords."
  :group 'sadl)

(defface sadl-type-face
  '((t (:inherit font-lock-type-face)))
  "How to highlight SADL built-in types."
  :group 'sadl)

(defface sadl-comment-face
  '((t (:inherit font-lock-comment-face)))
  "How to highlight SADL comments."
  :group 'sadl)

(defface sadl-class-face
  '((t (:inherit font-lock-function-face)))
  "How to highlight SADL classes."
  :group 'sadl)

(defface sadl-attribute-face
  '((t (:inherit font-lock-variable-face)))
  "How to highlight SADL attribute."
  :group 'sadl)

;;; Highlighting

(defconst sadl-keywords
  '("is"
    "a"
    "are"
    "described"
    "by"
    "of"
    "an"
    "type"
    "class"
    "value"
    "values"
    "are"
    "not"
    "the"
    "with"
    "single"
    "same"))

(defvar sadl--keyword-regexp
  (regexp-opt sadl-keywords 'words)
  "Regular expression for SADL keyword highlighting.")

(defconst sadl-types
  '("string"
    "date"
    "float"))

(defvar sadl--type-regexp
  (regexp-opt sadl-types 'words)
  "Regular expression for SADL type highlighting.")

(defconst sadl--comment-start "// ")

(defvar sadl--comment-regexp
  (rx "// " (+ anything) line-end)
  "Regular expression for SADL comment highlighting.")

(defvar sadl--class-regexp
  (rx upper-case (* lower-case))
  "Regular expression for SADL type highlighting.")

(defvar sadl--attribute-regexp
  (rx (+ lower-case))
  "Regular expression for SADL attribute highlighting.")

(defvar sadl-font-lock-defaults
  `(((,sadl--keyword-regexp . 'sadl-keyword-face)
     (,sadl--type-regexp . 'sadl-type-face)
     (,sadl--comment-regexp . 'sadl-comment-face)
     (,sadl--class-regexp . 'sadl-class-face)
     (,sadl--attribute-regexp . 'sadl-attribute-face)
     )
    nil nil nil
    (font-lock-extend-after-change-region-function . sadl--extend-after-change-region-function))
  "Highlighting instructions for SADL.")


(defvar sadl-mode-syntax-table nil "Syntax table for `sadl-mode'.")

(setq sadl-mode-syntax-table
      (let ((synTable (make-syntax-table)))
        ;; C++ style comment "//"
        (modify-syntax-entry ?\/ ". 12b" synTable)
        (modify-syntax-entry ?\n "> b" synTable)
        synTable))

;;; Default keybindings

(defvar sadl-mode-map
  (let ((map (make-sparse-keymap)))
    ;; (define-key map (kbd "C-c C-c") 'sadl-run-current-buffer)
    map)
  "Keymap for SADL mode.")

(cl-defmethod xref-backend-definitions ((_backend (eql elisp)) identifier)
  (require 'find-func)
  ;; FIXME: use information in source near point to filter results:
  ;; (dvc-log-edit ...) - exclude 'feature
  ;; (require 'dvc-log-edit) - only 'feature
  ;; Semantic may provide additional information
  ;;
  (let ((sym (intern-soft identifier)))
    (when sym
      (elisp--xref-find-definitions sym))))

;;; xref

(defun sadl--xref-backend () 'sadl)

(defun sadl--find-identifier (identifier)
  (save-excursion
    (goto-char 0)
    (message "FINDING %s" (concat identifier " is a"))
    (if (equal (re-search-forward (concat identifier " is a") nil t) nil)
        nil
        (point))))

(defun sadl--xref-find-definitions (identifier)
  (let ((loc (sadl--find-identifier identifier)))
    (if (equal loc nil)
        (list)
        (list
        (xref-make
          identifier
          (xref-make-buffer-location (current-buffer) loc))))))

(cl-defmethod xref-backend-definitions ((_backend (eql sadl)) identifier)
  (sadl--xref-find-definitions identifier))

;;; The mode itself

;;;###autoload
(define-derived-mode sadl-mode prog-mode "SADL"
  "A major mode for editing SADL files."
  (setq font-lock-defaults sadl-font-lock-defaults)
  (setq font-lock-multiline t)


  ;; xref
  (add-hook 'xref-backend-functions #'sadl--xref-backend nil t)

  ;; Comment syntax
  (set-syntax-table sadl-mode-syntax-table)
  (setq-local comment-start sadl--comment-start)
  (setq-local comment-end ""))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sadl\\'" . sadl-mode))

(provide 'sadl-mode)
;;; sadl.el ends here
