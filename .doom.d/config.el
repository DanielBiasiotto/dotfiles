;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Daniel Biasiotto"
       user-mail-address "daniel.biasiotto@edu.unito.it")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; F a c e

(use-package ewal
  :init (setq ewal-use-built-in-always-p nil
              ewal-use-built-in-on-failure-p t
              ewal-built-in-palette "sexy-material"))
(use-package ewal-doom-themes
  :init (progn
          (setq doom-theme-underline-parens t
                my:rice:font (font-spec
                              :family "SF Mono"
                              :weight 'medium
                              :size 8.0))
          (show-paren-mode +1)
          (global-hl-line-mode)
          (set-frame-font my:rice:font nil t)
          (add-to-list  'default-frame-alist
                        `(font . ,(font-xlfd-name my:rice:font))))
  :config (progn
            (load-theme 'ewal-doom-vibrant t)
            (enable-theme 'ewal-doom-vibrant)))

(setq display-line-numbers-type t)

;;;;;;;;;;;;;;;;;;;;;;;;;; M o d e l i n e

(defun custom-modeline-mode-icon ()
  (format " %s"
    (propertize icon
                'help-echo (format "Major-mode: `%s`" major-mode)
                'face `(:height 1.0 :family ,(all-the-icons-icon-family-for-buffer)))))

(setq doom-modeline-icon (display-graphic-p))
(setq doom-modeline-major-mode-icon t)
(setq doom-modeline-major-mode-color-icon t)
(setq doom-modeline-buffer-encoding nil)
(setq doom-modeline-height 15)
(custom-set-faces
  '(mode-line ((t (:family "SF Display" :weight semi-bold :height 1.0))))
  '(mode-line-inactive ((t (:family "SF Display" :height 1.0)))))
(display-battery-mode)
(setq display-time-day-and-date t)
(setq display-time-format "%I:%M %p")
(setq display-time-default-load-average nil)
(display-time)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; O r g + R o a m
(require 'org-superstar)
(setq org-superstar-headline-bullets-list '(
                                            "❱"
                                            "❯"
                                           ))
(setq org-superstar-special-todo-items t)
(setq org-superstar-todo-bullet-alist '(
                                         "❏"
                                         ))
(use-package org
  :hook
  (org-mode . company-latex-commands))

(add-hook 'org-mode-hook 'org-superstar-mode)
(setq org-directory "~/git/org/")
(setq org-roam-directory "~/git/org/roam")
(defvar-local journal-file-path "~/git/org/roam/BulletJournal.org")

(add-hook 'lisp-mode-hook 'my-buffer-face-mode-variable)

(after! org
  (setq org-capture-templates
  '(("t" "Todo" entry (file+headline todo-file-path "Tasks")
     "\n* TODO %?  %^G \nSCHEDULED: %^t\n  %U")
    ("r" "To Be Read" entry (file "~/Documents/Dropbox/Org/roam/Letture.org")
     "\n* TBR %?  %^G \n%U")
    ("j" "Bullet Journal" entry (file+olp+datetree journal-file-path)
     "** %<%H:%M> %?\n")
    ("r" "Roam"  entry (file org-roam-find-file) ;;capture-new-file non funge per qualche motivo
     "")
   )))

(after! org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "DOING(d)" "TBR(r)" "READING(e)"
                    "|" "READ(R)" "DONE(D)"))))

(defun org-archive-done-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (org-element-property :begin (org-element-at-point))))
   "/DONE" 'agenda))

(use-package org-noter
  :after org
  :config
  (setq org-noter-default-notes-file-names '("notes.org"))
  (setq org-noter-notes-search-path '("~/git/org/roam")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; N o v . e l

(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(defun my-nov-font-setup ()
  (face-remap-add-relative 'variable-pitch :family "Iosevka Etoile"
                                           :height 1.1))
(add-hook 'nov-mode-hook 'my-nov-font-setup)

(setq nov-text-width t)
(setq visual-fill-column-center-text t)
(add-hook 'nov-mode-hook 'visual-line-mode)
(add-hook 'nov-mode-hook 'visual-fill-column-mode)

(require 'justify-kp)
(setq nov-text-width t)

(defun my-nov-window-configuration-change-hook ()
  (my-nov-post-html-render-hook)
  (remove-hook 'window-configuration-change-hook
               'my-nov-window-configuration-change-hook
               t))

(defun my-nov-post-html-render-hook ()
  (if (get-buffer-window)
      (let ((max-width (pj-line-width))
            buffer-read-only)
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (when (not (looking-at "^[[:space:]]*$"))
              (goto-char (line-end-position))
              (when (> (shr-pixel-column) max-width)
                (goto-char (line-beginning-position))
                (pj-justify)))
            (forward-line 1))))
    (add-hook 'window-configuration-change-hook
              'my-nov-window-configuration-change-hook
              nil t)))

(add-hook 'nov-post-html-render-hook 'my-nov-post-html-render-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; D e f t

(use-package deft
  :after org
  :bind
  ("C-c d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; L e d g e r

(use-package ledger-mode
    :mode ("\\.dat\\'"
           "\\.ledger\\'")
    :custom (ledger-clear-whole-transactions t))

  (use-package flycheck-ledger :after ledger-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; S n i p p e t s

(use-package auto-activating-snippets
  :hook (LaTeX-mode . auto-activating-snippets-mode)
  :hook (org-mode . auto-activating-snippets-mode)
  :config
  (aas-set-snippets 'text-mode
                    ;; expand unconditionally
                    "o-" "ō"
                    "i-" "ī"
                    "a-" "ā"
                    "u-" "ū"
                    "e-" "ē")
  (aas-set-snippets 'latex-mode
                    ;; set condition!
                    :cond #'texmathp ; expand only while in math
                    "supp" "\\supp"
                    "On" "O(n)"
                    "O1" "O(1)"
                    "Olog" "O(\\log n)"
                    "Olon" "O(n \\log n)"
                    ;; bind to functions!
                    "//" (lambda () (interactive)
                             (yas-expand-snippet "\\frac{$1}{$2}$0"))
                    "Span" (lambda () (interactive)
                             (yas-expand-snippet "\\Span($1)$0"))))

(use-package! latex-auto-activating-snippets)

(use-package company
  :config
  (global-company-mode)
  (setq-default company-idle-delay 0)
)

(use-package company-math
  :config
  (add-to-list 'company-backends 'company-math-symbols-latex)
  ;; (add-to-list 'company-backends 'company-math-symbols-unicode)
  (setq company-math-allow-latex-symbols-in-faces t)
  ;; (add-to-list 'company-backends 'company-math-symbols-unicode)
  )

;; L S P
(use-package lsp
  )
(setq lsp-keymap-prefix "s-l")
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package dap-mode)
