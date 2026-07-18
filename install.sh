#!/usr/bin/env bash
set -e

MAXPACK_HOME="${MAXPACK_HOME:-$HOME/.maxpack}"
MAXPACK_REPO="https://github.com/achengli/maxpack.git"
MAXPACK_SOURCE="$(cd "$(dirname "$0")" && pwd)"

echo "=== maxpack installer ==="
echo ""

mkdir -p "$MAXPACK_HOME/bin"

if [ -d "$MAXPACK_HOME/repo/.git" ]; then
  echo "=> Updating maxpack..."
  git -C "$MAXPACK_HOME/repo" pull --rebase || true
elif [ -d "$MAXPACK_HOME/repo" ]; then
  echo "=> Reinstalling maxpack from local source: $MAXPACK_SOURCE"
  rm -rf "$MAXPACK_HOME/repo"
  mkdir -p "$MAXPACK_HOME/repo"
  cp -r "$MAXPACK_SOURCE"/* "$MAXPACK_HOME/repo/"
else
  if [ -f "$MAXPACK_SOURCE/maxpack.asd" ]; then
    echo "=> Installing maxpack from local source: $MAXPACK_SOURCE"
    mkdir -p "$MAXPACK_HOME/repo"
    cp -r "$MAXPACK_SOURCE"/* "$MAXPACK_HOME/repo/"
  else
    echo "=> Cloning maxpack..."
    git clone "$MAXPACK_REPO" "$MAXPACK_HOME/repo"
  fi
fi

cat > "$MAXPACK_HOME/bin/maxpack" << 'MAXPACK_CLI_SCRIPT'
#!/usr/bin/env bash
MAXPACK_HOME="${MAXPACK_HOME:-$HOME/.maxpack}"
MAXPACK_CLI_ARGS=""
for MP_ARG in "$@"; do
  MAXPACK_CLI_ARGS="$MAXPACK_CLI_ARGS \"$MP_ARG\""
done
exec sbcl --noinform --non-interactive \
  --eval "(require 'asdf)" \
  --eval "(push \"$MAXPACK_HOME/repo/\" asdf:*central-registry*)" \
  --eval "(asdf:load-system :maxpack)" \
  --eval "(maxpack:Maxpack-Cli $MAXPACK_CLI_ARGS)" \
  --quit
MAXPACK_CLI_SCRIPT

chmod +x "$MAXPACK_HOME/bin/maxpack"

if [ ! -f "$MAXPACK_HOME/package.list" ]; then
  cat > "$MAXPACK_HOME/package.list" << 'LIST'
# maxpack package list
# Add packages to install, one per line:
#   user/repo             — GitHub shorthand (installs to pkg/latest/)
#   user/repo@tag         — with a specific tag (installs to pkg/tag/)
#   https://gitlab.com/user/repo.git  — full git URL
#
# Example:
#   achengli/maxpack
LIST
fi

echo ""
echo "maxpack installed successfully."
echo ""
echo "Add this to your shell config (~/.bashrc, ~/.zshrc, etc.):"
echo "  export PATH=\"\$HOME/.maxpack/bin:\$PATH\""
echo ""
echo "=> Configuring ~/.maxima/maxima-init.mac ..."
MAXIMA_INIT="$HOME/.maxima/maxima-init.mac"
mkdir -p "$(dirname "$MAXIMA_INIT")"
LOAD_LINE="load(\"$HOME/.maxpack/repo/src/init.mac\");"
if [ -f "$MAXIMA_INIT" ] && grep -qF "$LOAD_LINE" "$MAXIMA_INIT" 2>/dev/null; then
  echo "   (already configured)"
else
  echo "$LOAD_LINE" >> "$MAXIMA_INIT"
  echo "   added load line to $MAXIMA_INIT"
fi
echo ""
echo "Package layout:"
echo "  ~/.maxpack/pkg-name/latest/   — default (updated via 'update')"
echo "  ~/.maxpack/pkg-name/v1.0/     — specific version"
echo ""
echo "Usage: maxpack install"
