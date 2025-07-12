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

(setq telega-emoji-use-images
      nil)

(map! :map global-map
      "C-c t"
      telega-prefix-map)

(setq display-line-numbers-type
      'visual)

(add-hook 'telega-load-hook
          'telega-notifications-mode)

(defvar my/emacs-deps-exec-path (seq-filter
                                 (lambda (p)
                                   (string-match-p
                                    "/nix/store/.*-emacs-packages-deps/bin"
                                    p))
                                 exec-path))

(advice-add #'envrc--update
            :after #'(lambda ()
                       (setq exec-path
                             (append exec-path
                                     my/emacs-deps-exec-path))))
