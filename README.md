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
