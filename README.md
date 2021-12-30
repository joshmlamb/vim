# vim
My personalised vim configuration.

## Setup
```
git clone https://github.com/joshmlamb/vim.git ~/.vim
cd ~/.vim
git submodule update --init --recursive
```

## Plugins
Details on how to manage plugins.

### Updating Plugins
```
cd ~/.vim
git submodule update --init --recursive
```

### Adding a Plugin
```
cd ~/.vim
git submodule add https://github.com/**/plugin.git pack/plugin-category/plugin-name/opt
```
Add the following to your `vimrc`:
```
!packadd plugin-name
```

### Removing a Plugin
This seems to be unnecessarily complex but is the recommended way.
```
git submodule deinit -f path/to/submodule
```
```
rm -rf .git/modules/path/to/submodule
```
```
git rm -f path/to/submodule
```
