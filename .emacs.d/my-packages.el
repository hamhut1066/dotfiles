;;; packages --- Summary:
;;; Commentary:
; ~/.emacs.d/my-packages.el

;;; Code:
(require 'cl)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

(defvar required-packages
  '(
    magit
    evil
    powerline-evil
    markdown-mode
    haskell-mode
    auto-complete
    flycheck
    monokai-theme
    jedi
    rainbow-delimiters
    rainbow-mode
    ghc
    dash-at-point
    virtualenvwrapper
    fic-mode
    go-mode
    smart-mode-line
    yasnippet
    angular-snippets
    auto-yasnippet
    ) "A list of packages to ensure are installed at launch.")

(defun packages-installed-p ()
  "Method to check if all packages are installed."
  (loop for p in required-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

; if not all packages are installed, check one by one and install the missing ones.
(unless (packages-installed-p)
  ; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'my-packages)
;;; my-packages.el ends here
