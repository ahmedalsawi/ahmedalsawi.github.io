---
title: "vscode Tips and Tricks"
date: 2019-06-02
toc: false
images:
tags:
  - vscode
---

# Recovering deleted files

If you deleted something through vscode, you can find at

`<mounted_disk>/.Trash-1000/files/<deleted_file_name>`

I found the solution at [github issue](https://github.com/Microsoft/vscode/issues/32078)

# Spelling checks

I use `spell-right` vscode extension for spelling suggestions.  

```
sudo apt-get install hunspell-en-us
ln -s /usr/share/hunspell/* ~/.config/Code/Dictionaries
```

then `Alt-Shift-p` to choose `spellRight: Select Dictionary` and it works!.