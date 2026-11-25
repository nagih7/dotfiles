#!/usr/bin/env bash
# Bootstrap this dotfiles checkout on a new machine.
#
# Idempotent: every step checks whether it is already satisfied and skips if so,
# so re-running is safe and cheap.
#
#   ./install.sh                 link configs + install editor tooling
#   ./install.sh --with-nix      additionally install Nix and the `nil` LSP
#   ./install.sh --link-only     only create the symlinks, install nothing
#
# Why `nil` needs --with-nix: nil ships no prebuilt binary, and building it from
# source requires the `nix` binary at compile time (its builtin crate's build.rs
# shells out to nix), so mason's cargo-based install cannot work without Nix.
# Nix is therefore the only route, and it is opt-in because it adds a daemon.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NVIM_MIN_MINOR=10 # lua/utils/os.lua uses vim.uv, which landed in 0.10
NVIM_VERSION="0.12.6"
TREE_SITTER_VERSION="0.25.10" # 0.27.x needs glibc 2.39; this runs on older hosts

WITH_NIX=0
LINK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --with-nix) WITH_NIX=1 ;;
    --link-only) LINK_ONLY=1 ;;
    -h | --help)
      sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "unknown option: $arg (try --help)" >&2
      exit 2
      ;;
  esac
done

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '    \033[2m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# Root is only ever used for distro packages; everything else stays per-user.
sudo_ok() { have sudo && sudo -n true 2>/dev/null; }

is_nixos() { [ -e /etc/NIXOS ]; }

# Run a headless nvim command. nvim exits 0 even when Lua raises, so detect
# trouble in the output itself; show it in full rather than a truncated tail,
# which previously hid the actual message and left only a stack traceback.
run_nvim() {
  local desc="$1" out rc=0
  shift
  out="$(nvim --headless "$@" +qa 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ] || printf '%s' "$out" | grep -qiE "^E[0-9]+:|stack traceback|Error executing"; then
    warn "$desc: reported a problem"
    printf '%s\n' "$out" | grep -vE "^\s*$" | tail -12 | sed 's/^/      /' >&2
  else
    skip "$desc: ok"
  fi
}

# ---------------------------------------------------------------- symlinks ---
# Relative targets, matching the existing layout (~/.zshrc -> dotfiles/.zshrc).
link() {
  local src="$REPO_ROOT/$1" dest="$HOME/$2"
  if [ ! -e "$src" ]; then
    warn "missing in repo, skipping: $1"
    return
  fi
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    skip "already linked: ~/$2"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    warn "existing ~/$2 moved to $(basename "$backup")"
  fi
  ln -s "$src" "$dest"
  log "linked ~/$2"
}

link_all() {
  log "Linking configs from $REPO_ROOT"
  link ".config/nvim" ".config/nvim"
  link ".config/starship.toml" ".config/starship.toml"
  link ".config/wezterm" ".config/wezterm"
  link ".zshrc" ".zshrc"
  link ".tmux.conf" ".tmux.conf"
}

# ------------------------------------------------------------------ neovim ---
nvim_minor() {
  have nvim || return 1
  nvim --version | head -1 | sed -n 's/^NVIM v[0-9]*\.\([0-9]*\).*/\1/p'
}

install_neovim() {
  log "Neovim"
  if is_nixos; then
    skip "NixOS: Neovim comes from the system config"
    return
  fi
  local minor
  minor="$(nvim_minor || echo 0)"
  if [ "${minor:-0}" -ge "$NVIM_MIN_MINOR" ] 2>/dev/null; then
    skip "already >= 0.$NVIM_MIN_MINOR ($(nvim --version | head -1))"
    return
  fi
  warn "Neovim is missing or older than 0.$NVIM_MIN_MINOR (vim.uv is required)"

  local arch tarball tmp url
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      warn "unsupported arch $(uname -m); install Neovim >= 0.$NVIM_MIN_MINOR manually"
      return
      ;;
  esac
  tarball="nvim-linux-${arch}.tar.gz"
  url="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${tarball}"
  tmp="$(mktemp -d)"

  log "downloading Neovim ${NVIM_VERSION} (${arch})"
  curl -fsSL --retry 3 -o "$tmp/$tarball" "$url"

  # The release publishes no checksum file, but the API exposes each asset's
  # digest; verify against it so a corrupted or swapped download is caught.
  local want got
  want="$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/tags/v${NVIM_VERSION}" |
    tr ',' '\n' | grep -A2 "\"name\": \"${tarball}\"" | sed -n 's/.*"digest": "sha256:\([a-f0-9]*\)".*/\1/p' | head -1)"
  got="$(sha256sum "$tmp/$tarball" | cut -d' ' -f1)"
  if [ -n "$want" ] && [ "$want" != "$got" ]; then
    rm -rf "$tmp"
    warn "checksum mismatch for $tarball (want $want, got $got) -- aborting"
    return 1
  fi
  [ -n "$want" ] || warn "could not fetch expected digest; proceeding on transport trust"

  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/nvim-linux-${arch}"
  tar -xzf "$tmp/$tarball" -C "$HOME/.local/opt"
  ln -sfn "$HOME/.local/opt/nvim-linux-${arch}/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
  log "installed $("$HOME/.local/bin/nvim" --version | head -1) to ~/.local/bin/nvim"
  warn "run 'rehash' (zsh) in existing shells, or they will keep the old nvim"
}

# ------------------------------------------------------------ distro tools ---
# gcc/make build treesitter parsers; node drives most mason LSP servers;
# python3-venv is needed by pip-based mason packages such as ansible-lint.
install_distro_deps() {
  log "Build tooling"
  if is_nixos; then
    skip "NixOS: provided by the system config"
    return
  fi
  if ! have apt-get; then
    warn "no apt-get; ensure a C compiler, make, node/npm and python venv exist"
    return
  fi
  local want=() pkg
  have cc || have gcc || want+=(build-essential)
  have make || want+=(build-essential)
  have node || want+=(nodejs)
  have npm || want+=(npm)
  python3 -c 'import ensurepip' >/dev/null 2>&1 || want+=(python3-venv)
  have rg || want+=(ripgrep)
  have fd || have fdfind || want+=(fd-find)
  have unzip || want+=(unzip)

  if [ ${#want[@]} -eq 0 ]; then
    skip "all present"
    return
  fi
  # Deduplicate (build-essential can be requested twice).
  mapfile -t want < <(printf '%s\n' "${want[@]}" | sort -u)
  if ! sudo_ok; then
    warn "need root to install: ${want[*]}"
    warn "run: sudo apt-get install -y ${want[*]}"
    return
  fi
  log "installing: ${want[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${want[@]}"
}

install_tree_sitter_cli() {
  log "tree-sitter CLI"
  if have tree-sitter; then
    skip "already installed ($(tree-sitter --version 2>/dev/null))"
    return
  fi
  if is_nixos; then
    skip "NixOS: provided by the system config"
    return
  fi
  local arch
  case "$(uname -m)" in
    x86_64) arch="x64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      skip "unsupported arch; optional, only needed for :TSInstallFromGrammar"
      return
      ;;
  esac
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL --retry 3 -o "$tmp/ts.gz" \
    "https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-linux-${arch}.gz"
  mkdir -p "$HOME/.local/bin"
  gunzip -c "$tmp/ts.gz" >"$HOME/.local/bin/tree-sitter"
  chmod +x "$HOME/.local/bin/tree-sitter"
  rm -rf "$tmp"
  log "installed tree-sitter ${TREE_SITTER_VERSION}"
}

# --------------------------------------------------------------- nix + nil ---
install_nix_and_nil() {
  log "Nix + nil (Nix LSP)"
  if is_nixos; then
    skip "NixOS: add 'nil' to your system or home-manager packages"
    return
  fi
  if ! have nix && [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
    log "installing Nix (multi-user, adds a daemon)"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL --retry 3 -o "$tmp/install-nix.sh" https://nixos.org/nix/install
    sh "$tmp/install-nix.sh" --daemon --yes
    rm -rf "$tmp"
  else
    skip "Nix already present"
  fi

  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
  if have nil || [ -x "$HOME/.nix-profile/bin/nil" ]; then
    skip "nil already installed"
  else
    log "installing nil from nixpkgs (prebuilt, from cache.nixos.org)"
    nix profile install nixpkgs#nil --extra-experimental-features 'nix-command flakes'
  fi
  warn "Nix PATH applies to new shells only; restart existing ones"
}

# -------------------------------------------------------- editor provisioning ---
provision_nvim() {
  log "Neovim plugins, parsers and LSP servers"
  if ! have nvim; then
    warn "no nvim on PATH; skipping"
    return
  fi
  # Restore pins from the tracked lockfile rather than resolving plugin HEADs.
  run_nvim "plugins (Lazy restore)" "+Lazy! restore"

  # On NixOS the parsers and language servers come from the system config:
  # nvim-treesitter sees is_nix and turns auto_install off, and mason ships
  # prebuilt binaries that assume an FHS layout and generally will not run.
  # Worse, core/env.lua prepends mason/bin to PATH, so a broken mason binary
  # would shadow the working Nix-provided one.
  if is_nixos; then
    skip "parsers: skipped, Nix provides them (auto_install is off here)"
    skip "mason: skipped, its prebuilt binaries do not run under NixOS"
    log "done; run ':checkhealth' to review"
    return
  fi

  # Guarded: this uses the master-branch nvim-treesitter API, which does not
  # exist on the rewritten main branch. Report instead of dumping a traceback.
  run_nvim "treesitter parsers" '+lua
    local ok_cfg, cfg = pcall(require, "nvim-treesitter.configs")
    local ok_ins, ins = pcall(require, "nvim-treesitter.install")
    if ok_cfg and ok_ins and cfg.get_ensure_installed_parsers then
      ins.ensure_installed_sync(cfg.get_ensure_installed_parsers())
    else
      io.stderr:write("nvim-treesitter master API unavailable; run :TSUpdate by hand\n")
    end'

  run_nvim "mason tools" "+MasonToolsInstallSync"
  log "done; run ':checkhealth' to review"
}

main() {
  link_all
  if [ "$LINK_ONLY" -eq 1 ]; then
    log "--link-only: stopping here"
    return
  fi
  install_neovim
  install_distro_deps
  install_tree_sitter_cli
  if [ "$WITH_NIX" -eq 1 ]; then
    install_nix_and_nil
  else
    skip "skipping Nix/nil (pass --with-nix to enable the Nix LSP)"
  fi
  provision_nvim
}

main "$@"
