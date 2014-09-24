# homebrew-phpbrew

Homebrew formulas for my personal PHP development.

## Setup

Tap

```bash
$ brew tap markwu/homebrew-php
```

## Install

Currently, I only support [phpbrew](https://github.com/phpbrew/phpbrew), [composer](http://getcomposer.org) and [ctags-better-php](https://gist.github.com/complex857/9570127).

```bash
$ brew install phpbrew
$ brew link --force icu4c
$ brew install composer
$ brew install ctags-better-php
```

It also supports phpbrew & composer's `self-update` command, you can update them by

```bash
$ phpbrew self-update
$ composer self-update
```

## Build

Before using it, please run `phpbrew init`.

And also add the following command to your bash/zshrc `source ~/.phpbrew/bashrc`.

Now, you can brew your own php. Take php 5.5.17 for examples:

```bash
$ phpbrew phpbrew install 5.5.17 +default +mysql +gettext=/usr/local/opt/gettext +iconv +ftp +exif +dba +openssl +soap +apxs2=/usr/local/bin/apxs
$ phpbrew switch 5.5.17
$ phpbrew ext install gd
$ phpbrew ext install opcache
```

By default, homebrew will download formula from bottle (A precompiled binary library) if available. But If you ecounter php-gd errors in compile or execution time. Especially after your upgrade your xcode. Try the following snippets.

```bash
$ phpberw rm gd fontconfig freetype jpeg libpng libtiff xz
$ phpbrew install gd --build-from-source
```
