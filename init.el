;; -*- lexical-binding: t; -*-
;; Startup Performance
;; The default is 800 kilobytes.  Measured in bytes.
(defun ingvarr/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'ingvarr/display-startup-time)

;; Settings
(setq-default
 ad-redefinition-action 'accept                   ; Silence warnings for redefinition
 auto-save-list-file-prefix nil                   ; Prevent tracking for auto-saves
 create-lockfiles nil                             ; Locks are more nuisance than blessing
 cursor-in-non-selected-windows t                 ; Hide the cursor in inactive windows
 cursor-type '(box . 2)                           ; Underline-shaped cursor
 custom-unlispify-menu-entries nil                ; Prefer kebab-case for titles
 custom-unlispify-tag-names nil                   ; Prefer kebab-case for symbols
 delete-by-moving-to-trash t                      ; Delete files to trash
 fill-column 80                                   ; Set width for automatic line breaks
 help-window-select t                             ; Focus new help windows when opened
 indent-tabs-mode nil                             ; Stop using tabs to indent
 inhibit-startup-screen t                         ; Disable start-up screen
 initial-scratch-message ""                       ; Empty the initial *scratch* buffer
 initial-major-mode #'org-mode                    ; Prefer `org-mode' for *scratch*
 mouse-yank-at-point t                            ; Yank at point rather than pointer
 native-comp-async-report-warnings-errors 'silent ; Skip error buffers
 kill-ring-max 128                                ; Maximum length of kill ring
 load-prefer-newer t                              ; Prefer the newest version of a file
 mark-ring-max 128                                ; Maximum length of mark ring
 read-process-output-max (* 1024 1024)            ; Increase read size for data chunks
 recenter-positions '(5 bottom)                   ; Set re-centering positions
 select-enable-clipboard t                        ; Merge system's and Emacs' clipboard
 sentence-end-double-space nil                    ; Use a single space after dots
 show-help-function nil                           ; Disable help text everywhere
 tab-always-indent 'complete                      ; Indent first then try completions
 tab-width 4                                      ; Smaller width for tab characters
 use-short-answers t                              ; Replace yes/no prompts with y/n
 window-combination-resize t                      ; Resize windows proportionally
 x-stretch-cursor nil                             ; Stretch cursor to the glyph width
 vc-follow-symlinks t                             ; Always follow the symlinks
 view-read-only t)                                ; Always open read-only buffers in view-mode
(blink-cursor-mode 0)                             ; Prefer a still cursor
(delete-selection-mode 1)                         ; Replace region when inserting text

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file))

(set-language-environment "UTF-8")
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; Smoother scrolling. Stolen from
;; https://www.reddit.com/r/emacs/comments/fwmqc8/how_to_stop_emacs_from_half_scrolling_from_bottom/fmpc2k1
(setq scroll-margin 1               ;; Add a margin when scrolling vertically
      scroll-conservatively 101     ;; Avoid recentering when scrolling far
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;;Turn off all crap
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(setq visible-bell t)       ; Set up the visible bell

(column-number-mode)
(global-display-line-numbers-mode t)
(global-hl-line-mode t)
(setq display-line-numbers-type 'relative)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Make frame transparency overridable
(defvar ingvarr/frame-transparency '(90 . 90))
;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha ingvarr/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,ingvarr/frame-transparency))

(defun load-if-exists (f)
  (if (file-exists-p (expand-file-name f))
      (load-file (expand-file-name f))))

(load-if-exists "~/.emacs.d/secrets.el.gpg")   
;; (load-if-exists "~/.emacs.d/secrets.el")

;; (load-library "~/.emacs.d/secrets.el.gpg")

;;Straight as package manager
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use use-package
(straight-use-package 'use-package)
;; automatically ensure every package exists (like :ensure or :straight)
(setq straight-use-package-by-default t)

;; ASYNC
;; Emacs look SIGNIFICANTLY less often which is a good thing.
;; asynchronous bytecode compilation and various other actions makes
(use-package async
  :defer t
  :init
  (dired-async-mode 1)
  (async-bytecomp-package-mode 1)
  :custom (async-bytecomp-allowed-packages '(all)))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("dired" (mode . dired-mode))
               ("org" (name . "^.*org$"))
               ("magit" (mode . magit-mode))
               ("Mastodon" (mode . mastodon-mode))
               ("IRC" (or (mode . circe-channel-mode) (mode . circe-server-mode)))
               ("web" (or (mode . web-mode) (mode . js2-mode)))
               ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
               ("mu4e" (or
                        (mode . mu4e-compose-mode)
                        (name . "\*mu4e\*")
                        ))
               ("programming" (or
                               (mode . clojure-mode)
                               (mode . clojurescript-mode)
                               (mode . python-mode)
                               (mode . c++-mode)))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))
               ))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-auto-mode 1)
            (ibuffer-switch-to-saved-filter-groups "default")))

(setq ibuffer-show-empty-filter-groups nil   ;; Don't show filter groups if there are no buffers in that group
      ibuffer-expert t   ;; Don't ask for confirmation to delete marked buffers
      uniquify-buffer-name-style 'forward ; Uniquify buffer names
      uniquify-separator "/"
      uniquify-after-kill-buffer-p t    ; rename after killing uniquified
      uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

(use-package autorevert
  :ensure nil
  :delight auto-revert-mode
  :bind ("C-x R" . revert-buffer)
  :custom (auto-revert-verbose nil)
  :config (global-auto-revert-mode))

(use-package dired
  :straight nil
  :after evil evil-collection
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (setq dired-kill-when-opening-new-dired-buffer t)
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))


(use-package dired-single
  :commands (dired dired-jump))


(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  (add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)))

(use-package dired-hide-dotfiles
  :after evil evil-collection
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package savehist
  :defer 2
  :config
  (setq history-length 25)
  (savehist-mode 1))

;; (use-package recentf
;;   :straight nil
;;   :disabled t
;;   :bind ("C-x C-r" . recentf-open-files)
;;   :init (recentf-mode)
;;   :custom
;;   (recentf-exclude (list "/scp:"
;;                          "/ssh:"
;;                          "/sudo:"
;;                          "/tmp/"
;;                          "~$"
;;                          "COMMIT_EDITMSG"))
;;   (recentf-max-menu-items 15)
;;   (recentf-max-saved-items 200)
;;   (recentf-save-file "~/.cache/emacs/recentf")
;;     ;; Save recent files every 5 minutes to manage abnormal output.
;;   :config (run-at-time nil (* 5 60) 'recentf-save-list))

(setq no-littering-etc-directory (expand-file-name "config/" user-emacs-directory))
(setq no-littering-var-directory (expand-file-name "data/" user-emacs-directory))
(use-package no-littering)
;; (setq auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;;  (add-to-list 'recentf-exclude      
;;             (recentf-expand-file-name no-littering-var-directory))
;;  (add-to-list 'recentf-exclude
;;               (recentf-expand-file-name no-littering-etc-directory))

(when (boundp 'native-comp-eln-load-path)
  (setcar native-comp-eln-load-path
          (expand-file-name (convert-standard-filename "data/eln-cache/")
                            user-emacs-directory)))

(use-package undo-fu
  :config
  (setq undo-limit 67108864) ; 64mb.
  (setq undo-strong-limit 100663296) ; 96mb.
  (setq undo-outer-limit 1006632960) ; 960mb.
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(use-package project
  :straight nil
  :demand t
  :bind ("M-s M-s" . project-find-file)
  :config
  ;; Optionally configure a function which returns the project root directory.
  ;; There are multiple reasonable alternatives to chose from.
  ;; 1. project.el (project-roots)
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project)))))

  (defun project-magit  ()
    (interactive)
    (let ((dir (project-root (project-current t))))
      (magit-status dir)))

  (define-key project-prefix-map "m" 'project-magit)
  (define-key project-prefix-map "d" 'project-dired)
  (setq project-switch-commands
        '((project-find-file "Find file" f)
          (project-dired "Dired" d)
          (project-vc-dir "VC-Dir" v)
          (project-eshell "Eshell" e)
          (project-shell "Shell" s)
          (project-magit "Magit" m)))

  (defvar project-root-markers
    '(".git" "spago.dhall" "CMakeList.txt" "package.clj"
      "package.json" "mix.exs" "Project.toml" ".project" "Cargo.toml"
      "qlfile"))

  (defun my/project-find-root (path)
    (let* ((this-dir (file-name-as-directory (file-truename path)))
           (parent-dir (expand-file-name (concat this-dir "../")))
           (system-root-dir (expand-file-name "/")))
      (cond
       ((my/project-root-p this-dir) (cons 'transient this-dir))
       ((equal system-root-dir this-dir) nil)
       (t (my/project-find-root parent-dir)))))

  (defun my/project-root-p (path)
    (let ((results (mapcar (lambda (marker)
                             (file-exists-p (concat path marker)))
                           project-root-markers)))
      (eval `(or ,@ results))))

  (add-to-list 'project-find-functions #'my/project-find-root))

;; Use only password-store
(use-package password-store)
;; Auth-Source-Pass
(use-package auth-source-pass
  :straight (:type built-in)
  :init
  (auth-source-pass-enable)
  :after password-store
  :config
  ;; Make sure it's the only mechanism
  (setq auth-source-debug t
        auth-source-gpg-encrypt-to user-mail-address
        auth-sources '("~/.authinfo"
                       "~/.authinfo.gpg"
                       password-store)))
;; I like the pass interface, so install that too
(use-package pass
  :after password-store)

(use-package vertico
  :straight (:files (:defaults "extensions/*"))
  :init (vertico-mode)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              ("C-<backspace>" . vertico-directory-up))
  :custom (vertico-cycle t))

(use-package marginalia
  :after vertico
  :init (marginalia-mode)
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil)))

(use-package orderless
  :custom
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles . (partial-completion)))))
  (completion-styles '(orderless flex)))

(use-package consult
  :bind  (;; Related to the control commands.
          ("<help> a" . consult-apropos)
          ("C-x b" . consult-buffer)
          ("C-x M-:" . consult-complex-command)
          ("C-c k" . consult-kmacro)
          ;; Related to the navigation.
          ("M-g a" . consult-org-agenda)
          ("M-g e" . consult-error)
          ("M-g g" . consult-goto-line)
          ("M-g h" . consult-org-heading)
          ("M-g i" . consult-imenu)
          ("M-g k" . consult-global-mark)
          ("M-g l" . consult-line)
          ("M-g m" . consult-mark)
          ("M-g o" . consult-outline)
          ("M-g I" . consult-project-imenu)
          ;; Related to the search and selection.
          ("M-s G" . consult-git-grep)
          ("M-s g" . consult-grep)
          ("M-s k" . consult-keep-lines)
          ("M-s l" . consult-locate)
          ("M-s m" . consult-multi-occur)
          ("M-s r" . consult-ripgrep)
          ("M-s u" . consult-focus-lines)
          ("M-s f" . consult-find)
          )
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  (consult-narrow-key "<")
  ;; (consult-project-root-function #'dw/get-project-root)
  ;; Provides consistent display for both `consult-register' and the register
  ;; preview when editing registers.
  (register-preview-delay 0)
  (register-preview-function #'consult-register-preview))

(define-key (current-global-map) [remap load-theme] 'consult-theme)
(define-key (current-global-map) [remap isearch-forward] 'consult-line)

(use-package consult-eglot
  :straight nil
  :after (consult eglot))

(use-package consult-yasnippet
  :straight t
  :after yasnippet)

(use-package consult-org-roam
  :straight nil
  :after org-roam
  :init
  (require 'consult-org-roam)
  ;; Activate the minor mode
  (consult-org-roam-mode 1)
  :custom
  ;; Use `ripgrep' for searching with `consult-org-roam-search'
  (consult-org-roam-grep-func #'consult-ripgrep)
  ;; Configure a custom narrow key for `consult-buffer'
  (consult-org-roam-buffer-narrow-key ?r)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers t)
  :config
  ;; Eventually suppress previewing for certain functions
  (consult-customize
   consult-org-roam-forward-links
   :preview-key (kbd "M-."))
  :bind
  ;; Define some convenient keybindings as an addition
  ("C-c n e" . consult-org-roam-file-find)
  ("C-c n b" . consult-org-roam-backlinks)
  ("C-c n l" . consult-org-roam-forward-links)
  ("C-c n r" . consult-org-roam-search))

(use-package consult-notes
  :straight nil
  ;;    :straight (:type git :host github :repo "mclear-tools/consult-notes")
  :after org-roam
  :commands (consult-notes
             consult-notes-search-in-all-notes
             ;; if using org-roam 
             consult-notes-org-roam-find-node
             consult-notes-org-roam-find-node-relation)
  :config
  (setq consult-notes-file-dir-sources '(("Org-Roam"  ?r "~/.personal/mind"))) ;; Set notes dir(s), see below
  ;; Set org-roam integration, denote integration, or org-heading integration e.g.:
  ;; (setq consult-notes-org-headings-files '("~/path/to/file1.org"
  ;; "~/path/to/file2.org"))
  (consult-notes-org-headings-mode)
  (when (locate-library "denote")
    (consult-notes-denote-mode)))

(use-package embark
  :bind ("C-." . embark-act))

(use-package helpful
  :commands (helpful-at-point
             helpful-callable
             helpful-command
             helpful-function
             helpful-key
             helpful-macro
             helpful-variable)
  :bind
  ([remap display-local-help] . helpful-at-point)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command))

(use-package general
  :after evil)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Needed for `:after char-fold' to work
(use-package char-fold
  :custom
  (char-fold-symmetric t)
  (search-default-mode #'char-fold-to-regexp))

(use-package reverse-im
  ;; :straight t ;; install `reverse-im' using straight.el
  :demand t ; always load it
  :after char-fold ; but only after `char-fold' is loaded
  :bind
  ("M-T" . reverse-im-translate-word) ; fix a word in wrong layout
  :custom
  (reverse-im-char-fold t) ; use lax matching
  (reverse-im-read-char-advice-function #'reverse-im-read-char-include)
  (reverse-im-input-methods '("russian-computer")) ; translate these methods
  :config
  (reverse-im-mode t)) ; turn the mode on

(use-package evil-nerd-commenter
  :after evil general
  :general
  ;; Vim key bindings
  (general-define-key
   :states '(normal motion visual)
   :keymaps 'override
   :prefix "SPC"
   "ci" '(evilnc-comment-or-uncomment-lines :which-key "Evil comment or uncomeent lines" )
   "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
   "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
   "cc" 'evilnc-copy-and-comment-lines
   "cp" 'evilnc-comment-or-uncomment-paragraphs
   "cr" 'comment-or-uncomment-region
   "cv" 'evilnc-toggle-invert-comment-line-by-line
   "."  'evilnc-copy-and-comment-operator
                                        ; if you prefer backslash key 
   "\\" 'evilnc-comment-operator ))

(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
(global-set-key (kbd "C-c l") 'evilnc-quick-comment-or-uncomment-to-the-line)
(global-set-key (kbd "C-c c") 'evilnc-copy-and-comment-lines)
(global-set-key (kbd "C-c p") 'evilnc-comment-or-uncomment-paragraphs)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;; You will most likely need to adjust this font size for your system!
(defvar ingvarr/default-font-size 100)
(defvar ingvarr/default-variable-font-size 110)

;; Font Configuration
;;       (set-face-attribute 'default nil :font "JetBrains Mono" :height ingvarr/default-font-size)
;; Set the fixed pitch face
;;        (set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height ingvarr/default-font-size)
;; Set the variable pitch face
;;          (set-face-attribute 'variable-pitch nil :font "Fira Code Nerd Font" :height ingvarr/default-variable-font-size :weight 'regular)


;; Font Configuration
(set-face-attribute 'default nil :font "CaskaydiaCove Nerd Font Mono" :height ingvarr/default-font-size)
;; (set-face-attribute 'default nil :font "Cascadia Code" :height ingvarr/default-font-size)
;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "CaskaydiaCove Nerd Font Mono" :height ingvarr/default-font-size)
;; (set-face-attribute 'fixed-pitch nil :font "Cascadia Code" :height ingvarr/default-font-size)
;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "CaskaydiaCove Nerd Font" :height ingvarr/default-variable-font-size :weight 'regular)
;; (set-face-attribute 'variable-pitch nil :font "Cascadia Code" :height ingvarr/default-variable-font-size :weight 'regular)



;; (defun ingvarr/set-font-faces ()
;;       (message "Setting faces!")
;;       (set-face-attribute 'default nil :font "Fira Code Nerd Font" :height ingvarr/default-font-size)

;;       ;; Set the fixed pitch face
;;       (set-face-attribute 'fixed-pitch nil :font "Fira Code Nerd Font" :height ingvarr/default-font-size)

;;       ;; Set the variable pitch face
;;       (set-face-attribute 'variable-pitch nil :font "Cantarell" :height ingvarr/default-variable-font-size :weight 'regular))

;;     (if (daemonp)
;;         (add-hook 'after-make-frame-functions
;;                   (lambda (frame)
;;                     ;; (setq doom-modeline-icon t)
;;                     (with-selected-frame frame
;;                       (ingvarr/set-font-faces))))
;;         (ingvarr/set-font-faces))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

(use-package nerd-icons-dired
  :after dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :after ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-completion
  :after (marginalia all-the-icons)
  :config
  (nerd-icons-completion-mode))

(use-package doom-themes)

;; (if (daemonp)
;;   (add-hook 'after-make-frame-functions
;;       (lambda (frame)
;;           (with-selected-frame frame
;;               (load-theme 'doom-palenight t))))
;;   (load-theme 'doom-palenight t))

(use-package catppuccin-theme
  :init (load-theme 'catppuccin t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 35)))

(use-package fancy-battery
:disabled t
  :config
    (setq fancy-battery-show-percentage t)
    (setq battery-update-interval 15)
    (if window-system
      (fancy-battery-mode)
      (display-battery-mode)))

(setq display-time-24hr-format t) ; 24-часовой временной формат в mode-line
(setq display-time-default-load-average nil)
(display-time-mode t)             ; показывать часы в mode-line
(size-indication-mode t)          ; размер файла в %-ах

(defun modeline-contitional-buffer-encoding ()
  "Hide \"LF UTF-8\" in modeline.

It is expected of files to be encoded with LF UTF-8, so only show
the encoding in the modeline if the encoding is worth notifying
the user."
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))
(add-hook 'after-change-major-mode-hook #'modeline-contitional-buffer-encoding)

(use-package page-break-lines
  :hook
  (dashboard-after-initialize . global-page-break-lines-mode))

(use-package dashboard
  ;; :after page-break-lines projectile
  :init      ;; tweak dashboard config before loading it
  (setq dashboard-display-icons-p t) ;; display icons on both GUI and terminal
  (setq dashboard-icon-type 'nerd-icons) ;; use `nerd-icons' package
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-set-init-info t)
  ;; (setq dashboard-init-info "This is an init message!")
  (setq dashboard-banner-logo-title "Richard Stallman is proud you!")
  (setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "/home/ingvarr/.emacs.d/logo/logo.jpg") ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-projects-backend 'project-el)
  (setq dashboard-week-agenda t)
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)
                          ))
  ;; (setq dashboard-page-seperator "\n\f\n")
  (setq dashboard-footer-messages '("Richard Stallman is proud you!"))
  (setq dashboard-footer-icon (nerd-icons-sucicon "nf-custom-emacs"
                                                  :height 1.1
                                                  :v-adjust -0.05
                                                  :face 'font-lock-keyword-face))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "nf-oct-file_text")
                                    (bookmarks . "nf-oct-book")))
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))
;; (add-to-list 'dashboard-items '(agenda) t)

(add-hook 'server-after-make-frame-hook (lambda()
                                          (switch-to-buffer dashboard-buffer-name)
                                          (dashboard-mode)
                                          (dashboard-insert-startupify-lists)
                                          (dashboard-refresh-buffer)))

(use-package visual-fill-column
  :defer t
  :config
  (setq visual-fill-column-center-text t)
  (setq visual-fill-column-width 120)
  (setq visual-fill-column-center-text t))

(use-package writeroom-mode
  :defer t
  :config
  (setq writeroom-maximize-window nil
        writeroom-mode-line t
        writeroom-global-effects nil ;; No need to have Writeroom do any of that silly stuff
        writeroom-extra-line-spacing 3) 
  (setq writeroom-width visual-fill-column-width)
  )

;;Setting up TODO's states
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)"))))
;;Can't set DONE if children not DONE 
(setq-default org-enforce-todo-dependencies t)

;; Colors and faces for TODO
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("MEETING" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))
;; I don't wan't the keywords in my exports by default
(setq-default org-export-with-todo-keywords nil)

(defun my/set-general-faces-org ()
  (my/buffer-face-mode-variable)
  (setq line-spacing 0.1
        org-pretty-entities t
        org-startup-indented t
        org-adapt-indentation nil)
  (variable-pitch-mode +1)
  (mapc
   (lambda (face) ;; Other fonts that require it are set to fixed-pitch.
     (set-face-attribute face nil :inherit 'fixed-pitch))
   (list 'org-block
         'org-table
         'org-verbatim
         'org-block-begin-line
         'org-block-end-line
         'org-meta-line
         'org-date
         'org-drawer
         'org-property-value
         'org-special-keyword
         'org-document-info-keyword))
  (mapc ;; This sets the fonts to a smaller size
   (lambda (face)
     (set-face-attribute face nil :height 1.1))
   (list 'org-document-info-keyword
         'org-block-begin-line
         'org-block-end-line
         'org-meta-line
         'org-drawer
         'org-property-value
         )))

(use-package org-bullets
  :disabled t
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-superstar)

;; (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
(with-eval-after-load 'org-superstar
  (setq org-superstar-item-bullet-alist
        '((?* . ?•)
          (?+ . ?➤)
          (?- . ?•)))
  (setq org-superstar-headline-bullets-list '(?\d))
  (setq org-superstar-special-todo-items t)
  (setq org-superstar-remove-leading-stars t)
  (setq org-hide-leading-stars t)
  ;; Enable custom bullets for TODO items
  (setq org-superstar-todo-bullet-alist
        '(("TODO" . ?☐)
          ("NEXT" . ?✒)
          ("HOLD" . ?✰)
          ("WAITING" . ?☕)
          ("CANCELLED" . ?✘)
          ("DONE" . ?✔)))
  (org-superstar-restart))

(setq org-ellipsis " ▼ ")

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package org-cliplink
  :after org)
(global-set-key (kbd "C-x p i") 'org-cliplink)

(defun custom-org-cliplink ()
  (interactive)
  (org-cliplink-insert-transformed-title
   (org-cliplink-clipboard-content)     ;take the URL from the CLIPBOARD
   (lambda (url title)
     (let* ((parsed-url (url-generic-parse-url url)) ;parse the url
            (clean-title
             (cond
              ;; if the host is github.com, cleanup the title
              ((string= (url-host parsed-url) "github.com")
               (replace-regexp-in-string "GitHub - .*: \\(.*\\)" "\\1" title))
              ;; otherwise keep the original title
              (t title))))
       ;; forward the title to the default org-cliplink transformer
       (org-cliplink-org-mode-link-transformer url clean-title)))))

(defun insert-url-as-org-link-sparse ()
  "If there's a URL on the clipboard, insert it as an org-mode
link in the form of [[url]]."
  (interactive)
  (let ((link (substring-no-properties (x-get-selection 'CLIPBOARD)))
        (url  "\\(http[s]?://\\|www\\.\\)"))
    (save-match-data
      (if (string-match url link)
          (insert (concat "[[" link "]]"))
        (error "No URL on the clipboard")))))

(defun insert-url-as-org-link-fancy ()
  "If there's a URL on the clipboard, insert it as an org-mode
link in the form of [[url][*]], and leave point at *."
  (interactive)
  (let ((link (substring-no-properties (x-get-selection 'CLIPBOARD)))
        (url  "\\(http[s]?://\\|www\\.\\)"))
    (save-match-data
      (if (string-match url link)
          (progn
            (insert (concat "[[" link "][]]"))
            (backward-char 2))
        (error "No URL on the clipboard")))))

(use-package org-modern
  :straight (:build t)
  :disabled t
  :after org
  :defer t
  :hook (org-mode . org-modern-mode)
  :hook (org-agenda-finalize . org-modern-agenda))

(use-package org-fancy-priorities
  :after (org all-the-icons)
  :disabled t
  :straight (:build t)
  :hook (org-mode        . org-fancy-priorities-mode)
  :hook (org-agenda-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list `(,(all-the-icons-faicon "flag"     :height 1.1 :v-adjust 0.0)
                                    ,(all-the-icons-faicon "arrow-up" :height 1.1 :v-adjust 0.0)
                                    ,(all-the-icons-faicon "square"   :height 1.1 :v-adjust 0.0))))

(use-package org-wild-notifier
  :after org
  :custom
  (alert-default-style 'libnotify)
  (org-wild-notifier-notification-title "Agenda Reminder")
  :config (org-wild-notifier-mode))

(use-package toc-org
  :after (org markdown-mode)
  :init
  (add-to-list 'org-tag-alist '("TOC" . ?T))
  :hook (org-mode . toc-org-enable)
  :hook (markdown-mode . toc-org-enable))

(use-package markdown-mode
  :mode ("\\.\\(md\\|markdown\\)\\'")
  :custom (markdown-command "/usr/bin/pandoc"))

(use-package markdown-preview-mode
  :commands markdown-preview-mode
  :custom
  (markdown-preview-javascript
   (list (concat "https://github.com/highlightjs/highlight.js/"
                 "9.15.6/highlight.min.js")
         "<script>
            $(document).on('mdContentChange', function() {
              $('pre code').each(function(i, block)  {
                hljs.highlightBlock(block);
              });
            });
          </script>"))
  (markdown-preview-stylesheets
   (list (concat "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/"
                 "3.0.1/github-markdown.min.css")
         (concat "https://github.com/highlightjs/highlight.js/"
                 "9.15.6/styles/github.min.css")

         "<style>
            .markdown-body {
              box-sizing: border-box;
              min-width: 200px;
              max-width: 980px;
              margin: 0 auto;
              padding: 45px;
            }

            @media (max-width: 767px) { .markdown-body { padding: 15px; } }
          </style>")))

;;;; Code Completion
(use-package corfu
  :straight (:files (:defaults "extensions/*"))
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-echo-documentation 0.25) ; Enable documentation for completions
  (corfu-preview-current 'insert) ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC" . corfu-insert-separator)
              ("TAB"     . corfu-next)
              ([tab]     . corfu-next)
              ("S-TAB"   . corfu-previous)
              ([backtab] . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET" . corfu-insert)
              ;; ("RET"     . nil) ;; leave my enter alone!
              )
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  :config
  (setq tab-always-indent 'complete)
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                              corfu-quit-no-match t
                              corfu-auto nil)
              (corfu-mode))))

;; Add extensions
(use-package cape
  :defer 10
  :bind ("C-c f" . cape-file)
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (defalias 'dabbrev-after-2 (cape-capf-prefix-length #'cape-dabbrev 2))
  (add-to-list 'completion-at-point-functions 'dabbrev-after-2 t)
  (cl-pushnew #'cape-file completion-at-point-functions)
  :config
  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

(use-package kind-icon
  :config
  (setq kind-icon-default-face 'corfu-default)
  (setq kind-icon-default-style '(:padding 0 :stroke 0 :margin 0 :radius 0 :height 0.9 :scale 1))
  (setq kind-icon-blend-frac 0.08)
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
  (add-hook 'counsel-load-theme #'(lambda () (interactive) (kind-icon-reset-cache)))
  (add-hook 'load-theme         #'(lambda () (interactive) (kind-icon-reset-cache))))

(use-package yasnippet
  :defer t
  :init
  (yas-global-mode)
  :hook ((prog-mode . yas-minor-mode)
         (text-mode . yas-minor-mode)))

(use-package yasnippet-snippets
  :defer t
  :after yasnippet
  :straight (:build t))

(use-package yatemplate
  :defer t
  :after yasnippet
  :straight (:build t))

(use-package smartparens
  :init
  (require 'smartparens-config)
  :config
  (smartparens-global-mode)
  (show-smartparens-global-mode t))

(use-package evil-smartparens
  :after (smartparens evil)
  :hook (smartparens-enabled-hook . evil-smartparens-mode))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :ensure   t
  :bind (("H-SPC" . set-rectangular-region-anchor)
         ("C-M-SPC" . set-rectangular-region-anchor)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C->" . mc/mark-all-like-this)
         ("C-c C-SPC" . mc/edit-lines)
         ))

(use-package rainbow-mode
  :delight
  :hook ((prog-mode text-mode) . rainbow-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :init
  (persp-mode))

(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

(use-package magit
  :commands magit-status
  :after auth-source-pass
  :hook (magit-process-find-password-functions . magit-process-password-auth-source)
  :custom
  ;; (magit-process-find-password-functions '(magit-process-password-auth-source)) 
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)
