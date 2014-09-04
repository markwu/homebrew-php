# homebrew-phpbrew

B
Homebrew formulas for my personal PHP development.

## Setup

Tap

```bash
$ brew tap markwu/homebrew-php
```

Currently, I only support [phpbrew](https://github.com/phpbrew/phpbrew), [composer](http://getcomposer.org) and [ctags-better-php](https://gist.github.com/complex857/9570127).

```bash
$ brew install phpbrew
$ brew install composer
$ brew install ctags-better-php
```

It also supports phpbrew & composer's `self-update` command, you can update them by

```bash
$ phpbrew self-update
$ composer self-update
```

That's all.
