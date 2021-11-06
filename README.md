### Install chezmoi

```bash
$ sh -c "$(curl -fsLS git.io/chezmoi)"
```

### Basic usage

```bash
$ chezmoi init <username|repo>
$ chezmoi apply
$ chezmoi update
```

### Commit changes

```bash
$ chezmoi add ~/.bashrc
$ chezmoi edit ~/.bashrc
$ chezmoi git add .
$ chezmoi git commit -- -m "Add bashrc file"
$ chezmoi git push
```
