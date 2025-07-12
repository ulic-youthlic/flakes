;;; config.el -*- lexical-binding: t; -*-

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
                 :size 20))
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
