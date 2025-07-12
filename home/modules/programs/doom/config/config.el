;; -*- lexical-binding: t; -*-

;;; Fix non-POSIX SHELL
(setq shell-file-name
      (executable-find "bash"))
(let ((fish-exe (executable-find "fish")))
  (setq-default vterm-shell
                fish-exe)
  (setq-default explicit-shell-file-name
                fish-exe))
(setq doom-font (font-spec
                 :family "Maple Mono NF CN"
                 :size 18)
      doom-variable-pitch-font (font-spec
                                :family "Source Han Serif SC"
                                :size 17)
      doom-emoji-font (font-spec
                       :family "Noto Color Emoji")
      doom-symbol-font (font-spec
                        :family "Maple Mono NF CN"
                        :size 18)
      doom-serif-font (font-spec
                       :family "Libertinus Serif"
                       :size 17)
      doom-big-font (font-spec
                     :family "Maple Mono NF CN"))
(setq doom-theme 'doom-gruvbox)
;;; Fix failure to loacate 'Symbols Nerd Font Mono' font
(setq nerd-icons-font-family "Maple Mono NF CN")

(map! :map global-map
      "C-c t"
      telega-prefix-map)

(setq display-line-numbers-type
      'relative)

(add-hook 'telega-load-hook
          'telega-notifications-mode)
