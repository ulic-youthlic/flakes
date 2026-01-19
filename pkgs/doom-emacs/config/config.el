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
                 :family "MonoLisa"
                 :size 20))
(setq doom-theme 'doom-one-light)
;;; Fix failure to locate 'Symbols Nerd Font Mono' font
(setq nerd-icons-font-family "Maple Mono NF CN")

(setq telega-emoji-use-images
      nil)

(map! :map global-map
      "C-c t"
      telega-prefix-map)

(setq display-line-numbers-type
      'relative)

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

(defun +telega-save-file-to-clipboard (msg)
  "Save file at point to clipboard.
NOTE: wayland only."
  (interactive (list (telega-msg-for-interactive)))
  (let ((file (telega-msg--content-file msg)))
    (unless file
      (user-error "No file associated with message"))
    (telega-file--download file
      :priority 32
      :update-callback
      (lambda (dfile)
        (telega-msg-redisplay msg)
        (message "Wait for downloading to finish…")
        (when (telega-file--downloaded-p dfile)
          (let* ((fpath (telega--tl-get dfile :local :path)))
            (shell-command (format "wl-copy < \"%s\"" fpath))
            (message (format "File saved to clipboard: %s" fpath))))))))

(map! :map global-map
      "C-c n"
      #'company-nixos-options)

(with-eval-after-load 'evil
  (scroll-on-jump-advice-add evil-redo)
  (scroll-on-jump-advice-add evil-jump-item)
  (scroll-on-jump-advice-add evil-jump-forward)
  (scroll-on-jump-advice-add evil-jump-backward)
  (scroll-on-jump-advice-add evil-ex-search-next)
  (scroll-on-jump-advice-add evil-ex-search-previous)
  (scroll-on-jump-advice-add evil-forward-paragraph)
  (scroll-on-jump-advice-add evil-backward-paragraph)
  (scroll-on-jump-advice-add evil-goto-mark)

  ;; Actions that themselves scroll.
  (scroll-on-jump-with-scroll-advice-add evil-goto-line)
  (scroll-on-jump-with-scroll-advice-add evil-goto-first-line)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-down)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-up)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-center)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-top)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-bottom)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-page-down)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-page-up))
(with-eval-after-load 'goto-chg
  (scroll-on-jump-advice-add goto-last-change)
  (scroll-on-jump-advice-add goto-last-change-reverse))

(global-set-key (kbd "<C-M-next>") (scroll-on-jump-interactive 'diff-hl-next-hunk))
(global-set-key (kbd "<C-M-prior>") (scroll-on-jump-interactive 'diff-hl-previous-hunk))

(use-package org-modern-mode
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-modern-hide-stars nil
        org-modern-table nil))
