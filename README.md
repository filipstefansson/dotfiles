# dotfiles

Dotfiles used by @filipstefansson.

### About

- Installs homebrew
- Installs git, node, Python tooling (etc) and a bunch of apps that I use
- Installs and configures zsh
- Installs a few vscode plugins
- Symlinks `.zshrc` to `~/code/other/dotfiles/.zshrc`
- Symlinks Starship and Ghostty config from `.config`
- Sets a few OSX settings (optional)

### New machine setup

Day-of steps for a fresh macOS install, in order (a couple of steps have ordering gotchas):

1. **Sign into 1Password** and enable its SSH agent — Settings → Developer →
   _Use the SSH agent_. Commit signing (below) depends on it.
2. **Install Xcode Command Line Tools** (Homebrew needs them):
   ```sh
   xcode-select --install
   ```
3. **Clone and install:**
   ```sh
   git clone https://github.com/filipstefansson/dotfiles ~/code/other/dotfiles
   cd ~/code/other/dotfiles
   ./install.sh
   ```
   This installs Homebrew + everything in the `Brewfile`, configures zsh, installs
   Node (fnm) and Python (uv), installs VS Code extensions, and symlinks the
   dotfiles. The repo can live anywhere — paths are auto-detected.
4. **Enable the `code` CLI:** open VS Code once, run _Shell Command: Install 'code'
   command in PATH_ from the command palette, then re-run `./vscode.sh` to install
   extensions (the first pass is skipped if `code` wasn't on PATH yet).
5. **Turn on Git commit signing:** in 1Password create/open an SSH key, then in
   `.gitconfig` paste its public key into `user.signingkey` and set
   `commit.gpgsign = true`. Add the same key to GitHub as a **Signing** key
   (Settings → SSH and GPG keys → New → type: Signing) for the _Verified_ badge.
   Full steps are commented inline in `.gitconfig`.
6. **Machine-specific paths** (Flutter, Android, etc.) go in `~/.config/zsh/local.zsh`
   — `install.sh` seeds it from the example on first run.
7. **macOS preferences** (optional, review first), then log out/in:
   ```sh
   ./.macos
   ```

Re-running `./install.sh` later is idempotent — it pulls latest and re-applies everything.

### Python

`uv` manages Python end to end — interpreters and project/tool workflows. `npm.sh`
runs `uv python install 3.14 --default`, which installs a default interpreter and
writes shims into `~/.local/bin` (prepended to PATH in `.zshrc`) so these resolve
consistently:

```sh
python
pip
python3
pip3
uv
```

### Java

Homebrew OpenJDK (`openjdk@21`, the current LTS) is the system-level JDK — pinned to 21 for Android/Flutter/Gradle compatibility. The shell exports `JAVA_HOME` and prepends the JDK `bin` directory because Homebrew keeps OpenJDK keg-only.

### Rust

`rustup` manages the toolchain. `rust.sh` installs it, runs `rustup update stable`, adds the `clippy`/`rustfmt`/`rust-analyzer` components, and installs `cargo-nextest` and `bacon` via `cargo-binstall`. The shell sources `~/.cargo/env` to put `~/.cargo/bin` on PATH, and `~/.cargo/config.toml` (symlinked) enables `sccache` caching and `target-cpu=native` for faster local builds.

### Usage

```sh
git clone https://github.com/filipstefansson/dotfiles
cd dotfiles
./install.sh
```

or manually:

```sh
./brew.sh
./zsh.sh
./npm.sh
ln -sfnv ~/code/other/dotfiles/.zshrc ~/.zshrc
```

### Local shell config

Machine-specific paths belong in `~/.config/zsh/local.zsh`. Start from:

```sh
cp .config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

### OSX settings

You can configure a few settings in OSX by running the `.macos` file.

```sh
./.macos
```

Make sure to walk through the file before running it!
