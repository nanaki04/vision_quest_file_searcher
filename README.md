# VisionQuest

**TODO: Add description**

## Installation

mix escript.build
sudo cp ./vq /usr/local/bin/vq_

edit .bash_aliases:

```
vq() {
  vq_ "$1" | xargs -o vim
}
```
