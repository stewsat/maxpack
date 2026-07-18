;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2026 BY-NC Yassin Achengli Benmouais <yassin_achengli@hotmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:        maxpack 
;;; Description:    Maxima package manager for SBCL lisp implementation.
;;; Author:         Yassin Achengli Benmouais
;;; License:        BSD-3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package #:maxpack)

;; ── Package spec parsing ────────────────────────────────────────────────────

(defun Parse-Package-Spec (Spec)
  "
  Parse a package spec: 'user/repo', 'user/repo@tag', or full git URL.
  Returns (values name version url).
  "
  (let* ((At-Pos (position #\@ Spec :from-end t))
         (Base (if At-Pos (subseq Spec 0 At-Pos) Spec))
         (Version (if At-Pos (subseq Spec (1+ At-Pos)) "latest")))
      (cond
        ((uiop:string-prefix-p "https://" Base)
         (let* ((Stripped (string-right-trim "/" (Strip-Git-Suffix Base)))
                (Name (car (last (uiop:split-string Stripped :separator "/")))))
           (values Name Version Base)))
        ((uiop:string-prefix-p "git@" Base)
         (let* ((Colon (position #\: Base))
                (Name (if Colon
                          (Strip-Git-Suffix (subseq Base (1+ Colon)))
                          Base)))
           (values Name Version Base)))
        (t
         (let* ((Parts (uiop:split-string Base :separator "/"))
                (User (first Parts))
                (Repo (second Parts)))
           (if (and User Repo)
               (values (Strip-Git-Suffix Repo) Version
                       (format nil "https://github.com/~a/~a.git" User (Strip-Git-Suffix Repo)))
                (values (Strip-Git-Suffix Base) Version Base)))))))

(defun Parse-Package-Name (Spec)
  "
  Extract just the package name from a spec string (strip .git, user/ prefix, etc).
  "
  (multiple-value-bind (Name Version) (Parse-Package-Spec Spec)
    (declare (ignore Version))
    Name))
;; ── Package directory layout ────────────────────────────────────────────────
;;

(defun Package-Dir (Name Version)
  "
  Return the filesystem path for a package@version.
  Version defaults to 'latest'.
  "
  (let ((Ver (if (or (not Version) (string= Version "latest"))
                 "latest"
                 Version)))
    (concatenate 'string *Maxpack-Home-Dir* "/" Name "/" Ver)))

(defun Pkg-Name-From-Ver-Dir (Ver-Dir)
  "
  Extract the package name from a version directory path.
  ~/.maxpack/foo/v1.0/ → 'foo'
  "
  (let* ((Parts (pathname-directory Ver-Dir))
         (Len (length Parts)))
    (when (>= Len 2)
      (nth (- Len 2) Parts))))

(defun Version-From-Ver-Dir (Ver-Dir)
  "
  Extract the version string from a version directory path.
  ~/.maxpack/foo/v1.0/ → 'v1.0'
  "
  (car (last (pathname-directory Ver-Dir))))

(defun Package-Dir-P (Dir)
  "
  Check if a directory under ~/.maxpack/ is a package container
  (not a system dir like bin, repo, etc).
  "
  (let ((Name (car (last (pathname-directory Dir)))))
    (and (not (member Name *Maxpack-Skip-Dirs* :test #'string=))
         (not (char= (char Name 0) #\.)))))

;; ── Package discovery ───────────────────────────────────────────────────────

(defun Read-Package-List ()
  "
  Read package.list and return a list of package specs.
  "
  (when (uiop:file-exists-p *Maxpack-Package-List-File*)
    (remove-if (lambda (S) (or (zerop (length S)) (char= (char S 0) #\#)))
               (mapcar #'Trim (uiop:read-file-lines *Maxpack-Package-List-File*)))))

(defun All-Version-Dirs ()
  "
  Return a list of all installed version directory pathnames.
  Scans ~/.maxpack/*/ for package dirs, then /*/ for version dirs.
  "
  (let ((Result '()))
    (dolist (Pkg-Dir (directory (concatenate 'string *Maxpack-Home-Dir* "/*/")))
      (when (Package-Dir-P Pkg-Dir)
        (dolist (Ver-Dir (directory (concatenate 'string (namestring Pkg-Dir) "*/")))
          (when (uiop:directory-exists-p Ver-Dir)
            (push Ver-Dir Result)))))
    (nreverse Result)))

(defun Find-Installed (Name &optional Version)
  "
  Find an installed package directory by name and optionally version.
  Returns the version-directory pathname or nil.
  "
  (let ((Ver (or Version "latest")))
    (let ((Dir (Package-Dir Name Ver)))
      (when (uiop:directory-exists-p Dir)
        Dir))))

(defun Find-Any-Version (Name)
  "
  Find any installed version of a package.
  Returns (name version . dir-path) or nil.
  "
  (dolist (Ver-Dir (All-Version-Dirs))
    (let ((Pkg-Name (Pkg-Name-From-Ver-Dir Ver-Dir)))
      (when (string= Pkg-Name Name)
        (return (cons Name (cons (Version-From-Ver-Dir Ver-Dir) Ver-Dir)))))))

(defun Delete-Dir (Path)
  "
  Safely delete a directory tree. Accepts strings or pathnames.
  "
  (let ((Dir (if (stringp Path)
                 (uiop:ensure-directory-pathname Path)
                 Path)))
    (uiop:delete-directory-tree Dir :validate t :if-does-not-exist :ignore)))

;; ── Manifest validation ─────────────────────────────────────────────────────

(defun Strip-Git-Suffix (S)
  "
  Remove trailing .git from a string, if present.
  Like 'foo.git' → 'foo', 'nonexistent' → 'nonexistent'.
  "
  (if (and S (uiop:string-suffix-p S ".git"))
      (subseq S 0 (- (length S) 4))
      S))

(defun Github-Raw-Url (Git-Url)
  "
  Convert a GitHub git URL to a raw.githubusercontent.com URL.
  https://github.com/user/repo.git → https://raw.githubusercontent.com/user/repo/main/manifest.toml
  "
  (let* ((Base (Strip-Git-Suffix Git-Url))
         (Parts (uiop:split-string Base :separator "/"))
         (User (nth (- (length Parts) 2) Parts))
         (Repo (car (last Parts))))
    (if (and User Repo (uiop:string-prefix-p "https://github.com/" Git-Url))
        (format nil "https://raw.githubusercontent.com/~a/~a/main/manifest.toml" User Repo)
        nil)))

(defun Fetch-Manifest (Git-Url)
  "
  Try to download manifest.toml from a repository before cloning.
  Returns the manifest alist on success, nil on failure.
  "
  (let ((Raw-Url (Github-Raw-Url Git-Url)))
    (when Raw-Url
      (Print-Line "Fetching manifest from ~a ..." Raw-Url)
      (let* ((Tmp-Dir (concatenate 'string *Maxpack-Home-Dir* "/.tmp/"))
             (Tmp-File (concatenate 'string Tmp-Dir "/manifest.toml")))
        (handler-case
            (progn
              (uiop:ensure-all-directories-exist (list Tmp-File))
              (uiop:run-program (list "curl" "-sL" "-o" Tmp-File Raw-Url)
                                :output t :error-output t)
              (when (uiop:file-exists-p Tmp-File)
                (let ((Manifest (Read-Manifest Tmp-Dir)))
                  (ignore-errors (uiop:delete-directory-tree Tmp-Dir :validate t :if-does-not-exist :ignore))
                  Manifest)))
          (error ()
            (ignore-errors (uiop:delete-directory-tree Tmp-Dir :validate t :if-does-not-exist :ignore))
            nil))))))

(defun Validate-Manifest (Manifest)
  "
  Check that a manifest contains all mandatory fields.
  Returns t if valid, nil otherwise.
  "
  (let ((Mandatory '("name" "version" "author" "repository" "description" "minver"))
        (Valid t))
    (dolist (Key Mandatory)
      (unless (cdr (assoc Key Manifest :test #'string=))
        (Print-Line "  Manifest missing mandatory field: ~a" Key)
        (setf Valid nil)))
    Valid))

(defun Git-Clone (Url Target-Dir)
  "
  Clone a git repository from Url into Target-Dir.
  "
  (Print-Line "Cloning ~a ..." Url)
  (uiop:run-program (list "git" "clone" Url Target-Dir)
                    :output t :error-output t))

(defun Git-Pull (Dir)
  "
  Run git pull --rebase in the given directory.
  "
  (Print-Line "Updating ~a ..." Dir)
  (uiop:run-program (list "git" "-C" (namestring Dir) "pull" "--rebase")
                    :output t :error-output t))

(defun Git-Checkout (Dir Tag)
  "
  Checkout a specific tag or branch in a git repository.
  "
  (uiop:run-program (list "git" "-C" (namestring Dir) "checkout" Tag)
                    :output t :error-output t))

;; ── ASDF registry ───────────────────────────────────────────────────────────

(defun Update-Asdf-Registry ()
  "
  Regenerate the ASDF registry file so installed packages are discoverable.
  "
  (uiop:ensure-all-directories-exist (list *Maxpack-Registry-File*))
  (with-open-file (Out *Maxpack-Registry-File* :direction :output
                       :if-exists :supersede :if-does-not-exist :create)
    (format Out ";;;; Generated by maxpack — do not edit~%")
    (format Out "(require 'asdf)~%~%")
    (dolist (Ver-Dir (All-Version-Dirs))
      (format Out "(push #P\"~a\" asdf:*central-registry*)~%" (namestring Ver-Dir)))
    (format Out "~%(asdf:clear-source-registry)~%"))
  (Print-Line "ASDF registry updated."))

;; ── Dependency resolution ───────────────────────────────────────────────────

(defun Ensure-Dependencies (Manifest)
  "
  Ensure all dependencies declared in the manifest are installed.
  "
  (dolist (Dep (Manifest-Dependencies Manifest))
    (multiple-value-bind (Name Version Url) (Parse-Package-Spec Dep)
      (declare (ignore Url))
      (unless (Find-Installed Name Version)
        (Print-Line "Installing dependency: ~a@~a" Name Version)
        (%mInstall-One Name Version Dep)))))

(defun %mInstall-One (Name Version Spec)
  "
  Internal: install a single package from a spec string.
  Validates manifest.toml before cloning.
  "
  (multiple-value-bind (Pkg-Name Pkg-Version Url) (Parse-Package-Spec Spec)
    (declare (ignore Pkg-Name))
    (let ((Target-Dir (Package-Dir Name Version)))
      (unless (uiop:directory-exists-p Target-Dir)
        ;; Validate manifest before cloning
        (let ((Manifest (Fetch-Manifest Url)))
          (if Manifest
              (if (Validate-Manifest Manifest)
                  (progn
                    (Print-Line "Manifest validated for ~a@~a" Name Version)
                    (uiop:ensure-all-directories-exist (list (concatenate 'string Target-Dir "/")))
                    (Git-Clone Url (namestring Target-Dir))
                    (unless (string= Pkg-Version "latest")
                      (Git-Checkout Target-Dir Pkg-Version))
                    (Print-Line "Installed ~a@~a" Name Version))
                  (progn
                    (Print-Line "Manifest validation failed for ~a. Install aborted." Name)
                    (return-from %mInstall-One nil)))
              (progn
                (Print-Line "No manifest.toml found for ~a. Install aborted." Name)
                (return-from %mInstall-One nil)))))
      (let ((Manifest (Read-Manifest Target-Dir)))
        (when Manifest
          (Ensure-Dependencies Manifest)))
      Target-Dir)))

;; ── Public API ──────────────────────────────────────────────────────────────

(defun mpHome ()
  "
  Return the maxpack home directory path.
  Called from Maxima as ?mpHome().
  "
  *Maxpack-Home-Dir*)

(defun mImport (Pkg-Name &optional Version)
  "
  Import a package: resolve dependencies, register with ASDF.
  Returns the package directory pathname on success, nil if not installed.
  "
  (let ((Pkg-Dir (or (Find-Installed Pkg-Name Version)
                     (let ((Found (Find-Any-Version Pkg-Name)))
                       (when Found (cddr Found))))))
    (if (not Pkg-Dir)
        (progn
          (Print-Line "Package ~a is not installed. Use install first." Pkg-Name)
          nil)
        (let ((Manifest (Read-Manifest Pkg-Dir)))
          (when Manifest
            (Ensure-Dependencies Manifest))
          (push (truename Pkg-Dir) asdf:*central-registry*)
          (asdf:clear-source-registry)
          (Print-Line "Imported ~a" Pkg-Name)
          Pkg-Dir))))

(defun mExists (Pkg-Name &optional Version)
  "
  Check if a package is installed.
  Returns the version string if installed, nil otherwise.
  "
  (if Version
      (let ((Found (Find-Installed Pkg-Name Version)))
        (when Found Version))
      (let ((Found (Find-Any-Version Pkg-Name)))
        (when Found (cadr Found)))))

(defun mInstall (&optional Pkg-Spec)
  "
  Install packages. If Pkg-Spec is provided, install that specific package.
  Otherwise install all packages listed in ~/.maxpack/package.list.

  Without a version, packages are installed to pkg/latest/.
  With a version (pkg@v1.0), they go to pkg/v1.0/.
  "
  (let ((Specs (if Pkg-Spec
                   (list Pkg-Spec)
                   (Read-Package-List))))
    (if (null Specs)
        (if Pkg-Spec
            (Print-Line "Usage: maxpack install <user/repo>")
            (Print-Line "No packages found in ~a. Add packages to install."
                        *Maxpack-Package-List-File*))
        (progn
          (dolist (Spec Specs)
            (multiple-value-bind (Name Version) (Parse-Package-Spec Spec)
              (let ((Target-Dir (Package-Dir Name Version)))
                (if (uiop:directory-exists-p Target-Dir)
                    (Print-Line "Package ~a@~a is already installed." Name Version)
                    (progn
                      (%mInstall-One Name Version Spec)
                      (let ((Manifest (Read-Manifest Target-Dir)))
                        (when Manifest
                          (Ensure-Dependencies Manifest))))))))
          (Update-Asdf-Registry)))))

(defun mList ()
  "
  List all installed packages.
  "
  (let ((Dirs (All-Version-Dirs)))
    (if (null Dirs)
        (Print-Line "No packages installed.")
        (dolist (Dir Dirs)
          (Print-Line "  ~a @ ~a"
                      (Pkg-Name-From-Ver-Dir Dir)
                      (Version-From-Ver-Dir Dir))))))

(defun mUninstall (Pkg-Name &optional Version)
  "
  Remove an installed package. If Version is nil, remove ALL versions.
  "
  (if Version
      (mUninstall-One Pkg-Name Version)
      (mUninstall-All Pkg-Name)))

(defun mUninstall-One (Pkg-Name Version)
  "
  Remove a single version of an installed package.
  "
  (let ((Target (Find-Installed Pkg-Name Version)))
    (if Target
        (progn
          (Print-Line "Removing ~a@~a ..." Pkg-Name Version)
          (Delete-Dir Target)
          (let ((Pkg-Dir (make-pathname :name nil :type nil :defaults Target)))
            (when (and (uiop:directory-exists-p Pkg-Dir)
                       (null (directory (concatenate 'string (namestring Pkg-Dir) "*/"))))
              (Delete-Dir Pkg-Dir)))
          (Update-Asdf-Registry)
          (Print-Line "Removed ~a@~a" Pkg-Name Version))
        (Print-Line "Package ~a@~a is not installed." Pkg-Name Version))))

(defun mUninstall-All (Pkg-Name)
  "
  Remove all installed versions of a package.
  "
  (let ((Removed 0))
    (dolist (Ver-Dir (All-Version-Dirs))
      (when (string= (Pkg-Name-From-Ver-Dir Ver-Dir) Pkg-Name)
        (Print-Line "Removing ~a@~a ..." Pkg-Name (Version-From-Ver-Dir Ver-Dir))
        (Delete-Dir Ver-Dir)
        (incf Removed)))
    (when (> Removed 0)
      (let ((Pkg-Dir (concatenate 'string *Maxpack-Home-Dir* "/" Pkg-Name)))
        (when (and (uiop:directory-exists-p Pkg-Dir)
                   (null (directory (concatenate 'string Pkg-Dir "/*/"))))
          (Delete-Dir Pkg-Dir))))
    (if (> Removed 0)
        (progn
          (Update-Asdf-Registry)
          (Print-Line "Removed ~a (~d version~:p)" Pkg-Name Removed))
        (Print-Line "Package ~a is not installed." Pkg-Name))))

(defun mRemove (Pkg-Name &optional Version)
  "
  Alias for mUninstall.
  "
  (mUninstall Pkg-Name Version))

(defun mUpdate (&optional Pkg-Name)
  "
  Update installed packages. Updates 'latest' versions.
  If Pkg-Name is provided, update only that package's latest.
  "
  (flet ((Is-Latest (Dir)
           (string= (Version-From-Ver-Dir Dir) "latest")))
    (let ((Dirs (if Pkg-Name
                    (let ((Found (Find-Installed Pkg-Name "latest")))
                      (if Found (list Found) nil))
                    (remove-if-not #'Is-Latest (All-Version-Dirs)))))
      (if (null Dirs)
          (if Pkg-Name
              (Print-Line "Package ~a has no 'latest' version installed." Pkg-Name)
              (Print-Line "No 'latest' packages to update."))
          (progn
            (dolist (Dir Dirs)
              (Git-Pull Dir))
            (Print-Line "All latest packages updated."))))))

(defun mSearch (&optional Query)
  "
  Search for packages.
  "
  (declare (ignore Query))
  (Print-Line "Search is not yet implemented."))

(defun mInfo (Pkg-Name &optional Version)
  "
  Show information about an installed package.
  "
  (let ((Pkg-Dir (or (Find-Installed Pkg-Name Version)
                     (let ((Found (Find-Any-Version Pkg-Name)))
                       (when Found (cddr Found))))))
    (if (not Pkg-Dir)
        (Print-Line "Package ~a is not installed." Pkg-Name)
        (let ((Manifest (Read-Manifest Pkg-Dir)))
          (if Manifest
              (progn
                (Print-Line "~a v~a" (or (Manifest-Get Manifest "name") Pkg-Name)
                            (or (Manifest-Get Manifest "version") "unknown"))
                (Print-Line "  Author:      ~a" (or (Manifest-Get Manifest "author") "—"))
                (Print-Line "  Description: ~a" (or (Manifest-Get Manifest "description") "—"))
                (Print-Line "  License:     ~a" (or (Manifest-Get Manifest "license") "—"))
                (Print-Line "  Repository:  ~a" (or (Manifest-Get Manifest "repository") "—"))
                (Print-Line "  Min maxima: ~a" (or (Manifest-Get Manifest "minver") "—"))
                (let ((Deps (Manifest-Dependencies Manifest)))
                  (when Deps
                    (Print-Line "  Dependencies:")
                    (dolist (Dep Deps)
                      (Print-Line "    - ~a" Dep)))))
              (Print-Line "~a (no manifest.toml found)" Pkg-Name))))))

(defun mVersion ()
  "
  Show maxpack version.
  "
  (Print-Line "maxpack v~a" *Maxpack-Version*))

;; ── CLI dispatcher ──────────────────────────────────────────────────────────

(defun Maxpack-Cli (&rest Args)
  "
  CLI dispatcher for terminal usage.
  Usage: maxpack {install|remove|list|update|import|exists|info|search|version|help} [arguments]
  "
  (let ((Command (string-downcase (or (first Args) "help")))
        (Target (second Args))
        (Extra (third Args))
        (Pkg-Name (when (second Args) (Parse-Package-Name (second Args)))))
    (cond
      ((string= Command "install")
       (mInstall Target))
      ((string= Command "remove")
       (if Pkg-Name
           (mRemove Pkg-Name Extra)
           (Print-Line "Usage: maxpack remove <package> [version]")))
      ((string= Command "list")
       (mList))
      ((string= Command "update")
       (mUpdate Target))
      ((string= Command "import")
       (if Pkg-Name
           (mImport Pkg-Name Extra)
           (Print-Line "Usage: maxpack import <package> [version]")))
      ((string= Command "exists")
       (if Pkg-Name
           (let ((V (mExists Pkg-Name Extra)))
             (if V
                 (Print-Line "~a@~a is installed." Pkg-Name V)
                 (Print-Line "~a is not installed." Pkg-Name)))
           (Print-Line "Usage: maxpack exists <package> [version]")))
      ((string= Command "info")
       (if Pkg-Name
           (mInfo Pkg-Name Extra)
           (Print-Line "Usage: maxpack info <package> [version]")))
      ((string= Command "search")
       (mSearch Target))
      ((string= Command "version")
       (mVersion))
      (t
       (Print-Line "maxpack — Maxima package manager v~a" *Maxpack-Version*)
       (Print-Line "")
       (Print-Line "Usage: maxpack <command> [arguments]")
       (Print-Line "")
       (Print-Line "Commands:")
       (Print-Line "  install [pkg]       Install packages from ~a" *Maxpack-Package-List-File*)
       (Print-Line "  remove <pkg> [ver]  Remove an installed package or version")
       (Print-Line "  list                List installed packages")
       (Print-Line "  update [pkg]        Update latest versions of packages")
       (Print-Line "  import <pkg> [ver]  Import an installed package (resolve deps)")
       (Print-Line "  exists <pkg> [ver]  Check if a package is installed")
       (Print-Line "  info <pkg> [ver]    Show package information")
       (Print-Line "  search [query]      Search for packages")
       (Print-Line "  version             Show maxpack version")
       (Print-Line "  help                Show this help")
       (Print-Line "")
       (Print-Line "Package directory layout:")
       (Print-Line "  $MAXPACK_HOME/pkg-name/latest/   — current version (updated via 'update')")
        (Print-Line "  $MAXPACK_HOME/pkg-name/v1.0/     — specific version")))))
