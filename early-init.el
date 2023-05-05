;; -*- lexical-binding: t; -*-
;;Setting up locale
(setq system-time-locale "ru_RU")
;;Turn off bild-on package manager "package.el"
(setq package-enable-at-startup nil)

;; Set background to mode darker
(add-to-list 'default-frame-alist '(foreground-color . "#ebdbb2"))
(add-to-list 'default-frame-alist '(background-color . "#282828")) 
(setq frame-background-mode 'dark)

;; Garbage Collections
(setq gc-cons-percentage 0.6)

;; Starting in a fullscreen mode
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
