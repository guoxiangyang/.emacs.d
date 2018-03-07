;;;;;;;;;;;;;package;;;;;;;;;;;;;;;;;;
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
	     '("popkit" . "https://elpa.popkit.org/packages/"))
;; '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ;; You might already have this line
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


;;;;;;;;;;;;;;;;;;;;;;;; init hooks ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'after-init-hook
          (lambda ()
            (load-theme 'tango-dark)
            ))
(add-hook 'sql-mode-hook
           (lambda () 
             (define-key sql-mode-map (kbd "C-j") 'sql-exec-select-text)))

(add-hook 'sql-mode-hook
           (lambda () 
             (toggle-truncate-lines)))

(add-hook 'find-file-hook (lambda () (linum-mode 1)))


;;;;;;;;;;;;;;;;;;;;;;;; misc settings  ;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default indent-tabs-mode nil)  
(setq-default tab-width 4) 
(setq-default c-basic-offset 4)
(c-set-offset 'case-label '+)
(push (cons "\\*shell\\*" display-buffer--same-window-action) display-buffer-alist)

;;;;;;;;;;;;;;;;;;;;;;;; flycheck with jslint ;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'json)
;; (require 'flycheck)
;; (defun my-parse-jslinter-warning (warning)
;;   (flycheck-error-new
;;    :line (1+ (cdr (assoc 'line warning)))
;;    :column (1+ (cdr (assoc 'column warning)))
;;    :message (cdr (assoc 'message warning))
;;    :level 'error
;;    :buffer (current-buffer)
;;    :checker 'javascript-jslinter))
;; (defun jslinter-error-parser (output checker buffer)
;;   (mapcar 'parse-jslinter-warning
;;           (cdr (assoc 'warnings (aref (json-read-from-string output) 0)))))
;; (flycheck-define-checker javascript-jslinter
;;   "A JavaScript syntax and style checker based on JSLinter.

;; See URL `https://github.com/tensor5/JSLinter'."
;;   :command ("/usr/local/bin/jslint" "--raw" source)
;;   :error-parser jslinter-error-parser
;;   :modes (js-mode js2-mode js3-mode))

(defun close-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))

;;;;;;;;;;;;;;;;;;;;;;;; load local el ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun load-directory (dir)
  (let ((load-it (lambda (f)
                   (load-file (concat (file-name-as-directory dir) f)))
                 ))
	(mapc load-it (directory-files dir nil "\\.el$"))))

(load-directory "~/.emacs.d/.local")


;;;;;;;;;;;;;;;;;;;;;;;; org-agenda ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-agenda-files (list "~/.gxy/todo.org"
                           ))

(setq org-columns-default-format
      "%25ITEM %TODO %3PRIORITY %TIMESTAMP")

(setq calendar-week-start-day 1
          calendar-day-name-array ["日" "一" "二" "三" "四" 
                                   "五" "六"]
          calendar-month-name-array ["一月" "二月" "三月" "四月" "五月"
                                     "六月" "七月" "八月" "九月" 
                                     "十月" "十一月" "十二月"])

(defun air-org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(defun air-org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))

(setq org-agenda-custom-commands
      '(("d" "Daily agenda and all TODOs"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "未完成的重要任务:")))
          (alltodo ""
                   ((org-agenda-skip-function '(or (air-org-skip-subtree-if-habit)
                                                   (air-org-skip-subtree-if-priority ?A)
                                                   (org-agenda-skip-if nil '(scheduled deadline))))
                    (org-agenda-overriding-header "所有一般任务:")))
          (agenda "" ((org-agenda-span 14)))
          )
         ((org-agenda-compact-blocks t)))))

(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
;; (setq initial-buffer-choice (lambda ()
;;                               (org-agenda nil "d")
;;                               (get-buffer "*Org Agenda*")
;;                               ;; (delete-other-windows)
;;                               ))  


;;;;;;;;;;; ket bind for vssh@ipad ;;;;;;;;;;;
(global-set-key "≈" 'execute-extended-command)
(global-set-key "∑" 'kill-ring-save)
(global-set-key "√" 'scroll-down-command)
(global-set-key "∫" 'backward-word)
(global-set-key "ƒ" 'forward-word)
(global-set-key "¯" 'beginning-of-buffer)
(global-set-key "˘" 'end-of-buffer)
(global-set-key "∂" 'kill-word)
(global-set-key (kbd "<backtab>") 'hs-toggle-hiding)
;; (global-set-key (kbd "C--") 'undo)


(require 'chinese-pyim)
(require 'chinese-pyim-basedict) ; 拼音词库设置，五笔用户 *不需要* 此行设置
(chinese-pyim-basedict-enable)   ; 拼音词库，五笔用户 *不需要* 此行设置

(use-package chinese-pyim
  :ensure nil
  :config
  ;; 激活 basedict 拼音词库
  (use-package chinese-pyim-basedict
    :ensure nil
    :config (chinese-pyim-basedict-enable))

  ;; 五笔用户使用 wbdict 词库
  ;; (use-package chinese-pyim-wbdict
  ;;   :ensure nil
  ;;   :config (chinese-pyim-wbdict-gbk-enable))

  (setq default-input-method "chinese-pyim")

  ;; 我使用全拼
  (setq pyim-default-scheme 'quanpin)

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  ;; (setq-default pyim-english-input-switch-functions
  ;;               '(pyim-probe-dynamic-english
  ;;                 pyim-probe-isearch-mode
  ;;                 pyim-probe-program-mode
  ;;                 pyim-probe-org-structure-template))

  ;; (setq-default pyim-punctuation-half-width-functions
  ;;               '(pyim-probe-punctuation-line-beginning
  ;;                 pyim-probe-punctuation-after-punctuation))

  ;; 开启拼音搜索功能
  (setq pyim-isearch-enable-pinyin-search t)

  ;; 使用 pupup-el 来绘制选词框
  (setq pyim-page-tooltip 'popup)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 5)

  ;; 让 Emacs 启动时自动加载 pyim 词库
  (add-hook 'emacs-startup-hook
            #'(lambda () (pyim-restart-1 t)))
  :bind
  (("M-j" . pyim-convert-code-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-;" . pyim-delete-word-from-personal-buffer)))




(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum-format "%4d│")
 '(package-selected-packages
   (quote
    (ego bm dired-hacks-utils dired-narrow cquery lsp-mode tern-context-coloring tern-auto-complete company-tern company rust-mode magit org-alert js3-mode js2-mode flycheck eslint-fix chinese-pyim-greatdict chinese-pyim markdown-mode json-mode web-mode flymake-jslint)))
 '(safe-local-variable-values
   (quote
    ((org-export-html-style . "<link rel=\"stylesheet\" type=\"text/css\" href=\"stylesheet.css\" />")
     (org-export-html-style . "<link rel=\"stylesheet\"                type=\"text/css\" href=\"slides.css\" />")
     (org-export-html-style . "&lt;link rel=\"stylesheet\"                type=\"text/css\" href=\"slides.css\" /&gt;"))))
 '(truncate-lines t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'auto-mode-alist '("\\.html\\'" .     web-mode))
(add-to-list 'auto-mode-alist '("\\.htm\\'" .      web-mode))
(add-to-list 'auto-mode-alist '("\\.hjs\\'" .      web-mode))
(add-to-list 'auto-mode-alist '("\\.text\\'" .     markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" .       markdown-mode))

(require 'ansi-color)
(setq literary-cow-text "")
(defun literary-cow-on-http-data (proc string)
  (setq literary-cow-text (concat literary-cow-text string)))

(defun literary-cow-on-proc-state-changed (proc string)
  (org-agenda nil "d")
  (with-current-buffer "*Org Agenda*"
    (setq agenda-text (buffer-string))
    (quit-window))
  (with-current-buffer "*literary-cow*"
    (read-only-mode -1)
    (erase-buffer)
    (insert (substring literary-cow-text (+ 4 (string-match-p (regexp-quote "\r\n\r\n") literary-cow-text))))
    (ansi-color-apply-on-region (point-min) (point-max))
    (insert agenda-text)
    (read-only-mode)
    (beginning-of-buffer)))

(defun literary-cow-refresh ()
  "refresh a new literary cowsay text"
  (interactive)
  (with-current-buffer "*literary-cow*"
    (message "requesting http://literary-cow.cc")
    (setq literary-cow-text nil)
    (setq buf (get-buffer "*literary-cow*"))
    (setq proc (open-network-stream "cowsay" buf "literary-cow.cc" 80))
    (set-process-sentinel proc 'literary-cow-on-proc-state-changed)
    (set-process-filter proc 'literary-cow-on-http-data)
    (process-send-string proc "GET /shici?format=cowsay&color=rainbow HTTP/1.1\r\nHost: literary-cow.cc\r\n\r\n")))

(defun literary-cow-init ()
  "Init literary literary-cow"
  (interactive)
  (get-buffer-create "*literary-cow*")
  (with-current-buffer "*literary-cow*"
    (literary-cow-refresh)
    (local-set-key "g" 'literary-cow-refresh) ))

(setf initial-buffer-choice
      (lambda ()
        (literary-cow-init)
        (switch-to-buffer "*literary-cow*") ))


(require 'dired-narrow)
(use-package dired-narrow
  :ensure t
  :bind (:map dired-mode-map
              ("/" . dired-narrow-regexp)))

(require 'bm)
(use-package bm
  :ensure t
  :demand t

  :init
  ;; restore on load (even before you require bm)
  (setq bm-restore-repository-on-load t)


  :config
  ;; Allow cross-buffer 'next'
  (setq bm-cycle-all-buffers t)

  ;; where to store persistant files
  (setq bm-repository-file "~/.emacs.d/bm-repository")

  ;; save bookmarks
  (setq-default bm-buffer-persistence t)

  ;; Loading the repository from file when on start up.
  (add-hook' after-init-hook 'bm-repository-load)

  ;; Restoring bookmarks when on file find.
  (add-hook 'find-file-hooks 'bm-buffer-restore)

  ;; Saving bookmarks
  (add-hook 'kill-buffer-hook #'bm-buffer-save)

  ;; Saving the repository to file when on exit.
  ;; kill-buffer-hook is not called when Emacs is killed, so we
  ;; must save all bookmarks first.
  (add-hook 'kill-emacs-hook #'(lambda nil
                                 (bm-buffer-save-all)
                                 (bm-repository-save)))

  ;; The `after-save-hook' is not necessary to use to achieve persistence,
  ;; but it makes the bookmark data in repository more in sync with the file
  ;; state.
  (add-hook 'after-save-hook #'bm-buffer-save)

  ;; Restoring bookmarks
  (add-hook 'find-file-hooks   #'bm-buffer-restore)
  (add-hook 'after-revert-hook #'bm-buffer-restore)

  ;; The `after-revert-hook' is not necessary to use to achieve persistence,
  ;; but it makes the bookmark data in repository more in sync with the file
  ;; state. This hook might cause trouble when using packages
  ;; that automatically reverts the buffer (like vc after a check-in).
  ;; This can easily be avoided if the package provides a hook that is
  ;; called before the buffer is reverted (like `vc-before-checkin-hook').
  ;; Then new bookmarks can be saved before the buffer is reverted.
  ;; Make sure bookmarks is saved before check-in (and revert-buffer)
  (add-hook 'vc-before-checkin-hook #'bm-buffer-save)


  ;; :bind (("C-." . bm-next)
  ;;        ("C-," . bm-previous)
  ;;        ("C-u" . bm-toggle))
  )

;; (global-set-key (kbd "<C-f2>") 'bm-toggle)
;; (global-set-key (kbd "<f2>")   'bm-next)
;; (global-set-key (kbd "<S-f2>") 'bm-previous)

;; (global-set-key (kbd "C-u") 'bm-toggle)
;; (global-set-key (kbd "C--") 'bm-next)
;; (global-set-key (kbd "C-=") 'bm-previous)


(dolist (key '("\C-t" ))
  (global-unset-key key))
