(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-frame-fullscreen)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)
(column-number-mode 1)
(setq-default display-fill-column-indicator-column 80)
(setq display-fill-column-indicator-character "|")
(add-hook 'c++-mode-hook (lambda ()
			   (display-fill-column-indicator-mode)))
(add-hook 'c-mode-hook (lambda ()
			 (display-fill-column-indicator-mode)))
(add-hook 'vhdl-mode-hook (lambda ()
			 (display-fill-column-indicator-mode)))

(setq backup-directory-alist `(("." . "~/.emacs.d/saves")))
(setq backup-by-copying t)

(use-package zerodark-theme
  :ensure t
  :init
  (load-theme 'zerodark t))

(setq ring-bell-function 'ignore)

(when window-system (global-hl-line-mode t))

(when window-system (global-prettify-symbols-mode t))

(use-package beacon
  :ensure t
  :init
  (beacon-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :init
  (rainbow-delimiters-mode 1))

(use-package dashboard
  :ensure t
  :init
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 10)))
  (setq dashboard-center-content t))

(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
(setq display-time-format "%a %e %b %T")
(setq display-time-interval 1)
(display-time-mode)

(global-set-key (kbd "C-x b") 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

(defun kill-current-buffer ()
  (interactive)
  (kill-buffer nil))
(global-set-key (kbd "C-x k") 'kill-current-buffer)

(defun kill-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))
(global-set-key (kbd "C-x C-k") 'kill-all-buffers)

(setq electric-pair-pairs '(
			    (?\( . ?\))
			    (?\[ . ?\])
			    (?\{ . ?\})
			    (?\" . ?\")
			    ))
(electric-pair-mode t)

(defun copy-whole-line()
  (interactive)
  ; Return cursor back to where it started at end of command
  (save-excursion
    ; Make argument the latest kill in the kill ring -- yank pointer set to it
    (kill-new
     (buffer-substring
      (point-at-bol)
      (point-at-eol)))))
(global-set-key (kbd "C-c l") 'copy-whole-line)

(use-package popup-kill-ring
  :ensure t
  :bind ("M-y" . popup-kill-ring))

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode)
  :bind
  ("C-x C-u" . undo-tree-visualize))

(setq undo-tree-auto-save-history nil)

(defun my-query-replace-selected-region ()
  (interactive)
  (when (use-region-p)
    (let* ((selected-text (buffer-substring-no-properties (region-beginning) (region-end)))
	   (replacement (read-string (format "Replace \"%s\" with: " selected-text))))
      (deactivate-mark) ; Deactivate the mark to clear the selection
      (query-replace selected-text replacement nil (point-min) (point-max)))))

(global-set-key (kbd "C-%") 'my-query-replace-selected-region)

(defvar my-term-shell "/bin/zsh")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

(global-set-key (kbd "<s-return>") 'ansi-term)

(defalias 'yes-or-no-p 'y-or-n-p)

(defun config-edit ()
  (interactive)
  (find-file "~/.emacs.d/config.org"))

(defun config-reload ()
  (interactive)
  (org-babel-load-file "~/.emacs.d/config.org"))

(global-set-key (kbd "C-c e") 'config-edit)
(global-set-key (kbd "C-c r") 'config-reload)

(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)

(global-set-key (kbd "<f5>") 'compile)

(use-package which-key
  :ensure t
  :init
  (which-key-mode))

;; Allow ido to match substrings
(setq ido-enable-flex-matching nil)
;; If buffer does not exist, create it
(setq ido-create-new-buffer 'always)
(setq ido-everywhere t)
(ido-mode 1)

(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-vertical-mode 1))
(setq ido-vertical-define-keys 'C-n-and-C-p-only)

(use-package smex
  :ensure t
  :bind (("M-x" . smex)
	 ("C-c C-c M-x" . execute-extended-command)))

(setf dired-kill-when-opening-new-dired-buffer t)

(use-package company
  :ensure t
  :config
  ;; Delay time before company kicks in
  (setq company-idle-delay 0)
  ;; Length of token before company kicks in
  (setq company-minimum-prefix-length 3))

;;(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)

(with-eval-after-load 'company
  (define-key company-active-map (kbd "RET") #'company-complete))
;; (define-key company-active-map (kbd "SPC") #'company-abort))

(use-package company-irony
  :ensure t
  :config
  (add-to-list 'company-backends 'company-irony))

(use-package irony
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode)
                 . ("clangd"
                    "-j=8"
                    "--log=error"
                    "--malloc-trim"
                    "--background-index"
                    "--clang-tidy"
                    "--cross-file-rename"
                    "--completion-style=detailed"
                    "--pch-storage=memory"
                    "--header-insertion=never"
                    "--header-insertion-decorators=0"))
               '((cmake-mode)
                 . ("cmake-language-server"))))

(use-package clang-format
  :ensure t
  :bind (("C-c f" . clang-format-buffer)))

(use-package highlight-doxygen
  :ensure t
  :config (highlight-doxygen-global-mode))

(use-package meson-mode
  :ensure t)

(use-package cmake-mode
  :ensure t)

(setq vhdl-standard '(VHDL'08 nil))
(add-hook 'vhdl-mode-hook
	  (lambda () (local-set-key (kbd "C-c f") 'vhdl-beautify-buffer)))
(add-hook 'vhdl-mode-hook
	  (lambda () (setq vhdl-basic-offset 2)))

;; (defun my-vhdl-indent-generic-instantiation ()
;;   "Indent VHDL generic package instantiation correctly."
;;   (interactive)
;;   (let (margin (current-indentation))
;;     (when (looking-at ".*package.*is new")
;;       (message "Found package instantiation. Decrementing point.")	
;;       (indent-to (margin (-vhdl-basic-offset))))))
;; (add-hook 'vhdl-special-indent-hook 'my-vhdl-indent-generic-instantiation)

(use-package yasnippet
  :ensure t
  :config
  (use-package yasnippet-snippets
    :ensure t)
  (yas-reload-all)
  :bind
  (("C-x y" . yas-describe-tables)))

(add-hook 'c++-mode-hook 'yas-minor-mode)
(add-hook 'c-mode-hook 'yas-minor-mode)
(add-hook 'vhdl-mode-hook 'yas-minor-mode)

(defun maybe-load-template ()
  (interactive)
  (cond
   ((and (string-match "\\.cpp$" (buffer-file-name))
	 (eq 1 (point-max)))
    (insert-file-contents "~/.emacs.d/templates/template.cpp"))
   ((and (string-match "\\.hpp$" (buffer-file-name))
	 (eq 1 (point-max)))
    (insert-file-contents "~/.emacs.d/templates/template.hpp"))
   (t
    (message "Didn't recognise template for %s" (buffer-file-name)))))

(add-hook 'find-file-hooks 'maybe-load-template)

;; Setup use-package just in case everything isn't already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Enable use-package
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)
(use-package org
  :pin gnu)

;; Must do this so the agenda knows where to look for my files
(setq org-agenda-files '("~/org"))

;; When a TODO is set to a done state, record a timestamp
(setq org-log-done 'time)

;; Follow the links
(setq org-return-follows-link  t)

;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; Make the indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)

;; Remap the change priority keys to use the UP or DOWN key
(define-key org-mode-map (kbd "C-c <up>") 'org-priority-up)
(define-key org-mode-map (kbd "C-c <down>") 'org-priority-down)

;; Shortcuts for storing links, viewing the agenda, and starting a capture
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)

;; When you want to change the level of an org item, use SMR
(define-key org-mode-map (kbd "C-c C-g C-r") 'org-shiftmetaright)

;; Hide the markers so you just see bold text as BOLD-TEXT and not *BOLD-TEXT*
(setq org-hide-emphasis-markers t)

;; Wrap the lines in org mode so that things are easier to read
(add-hook 'org-mode-hook 'visual-line-mode)

;; TODO states
(setq org-todo-keywords
      '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )
        ))

;; TODO colors
(setq org-todo-keyword-faces
      '(
        ("TODO" . (:foreground "GoldenRod" :weight bold))
        ("PLANNING" . (:foreground "DeepPink" :weight bold))
        ("IN-PROGRESS" . (:foreground "Cyan" :weight bold))
        ("VERIFYING" . (:foreground "DarkOrange" :weight bold))
        ("BLOCKED" . (:foreground "Red" :weight bold))
        ("DONE" . (:foreground "LimeGreen" :weight bold))
        ("OBE" . (:foreground "LimeGreen" :weight bold))
        ("WONT-DO" . (:foreground "LimeGreen" :weight bold))
        ))

(setq org-capture-templates
      '(    
        ("j" "Work Log Entry"
         entry (file+datetree "~/Documents/org/work-log.org")
         "* %?"
         :empty-lines 0)

        ("g" "General To-Do"
         entry (file+headline "~/Documents/org/todos.org" "General Tasks")
         "* TODO [#B] %?\n:Created: %T\n "
         :empty-lines 0)

        ("m" "Meeting"
         entry (file+datetree "~/Documents/org/meetings.org")
             "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
             :tree-type week
             :clock-in t
             :clock-resume t
             :empty-lines 0)

        ))
