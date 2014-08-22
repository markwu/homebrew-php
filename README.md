# homebrew-phpbrew

Homebrew formula for [phpbrew](https://github.com/c9s/phpbrew)!

## Setup

Tap

```bash
$ brew tap chadrien/homebrew-phpbrew
```

Install

```bash
$ brew install phpbrew
```

Then do what's told while installing for immediate use

Make sure icu4c is linked before using phpbrew. Run following command to relink.
```bash
$ brew unlink icu4c && brew link icu4c --force
```

To start using it, please run
```bash
$ phpbrew init
```

And also add the following command to your bash/zshrc
```bash
$ source ~/.phpbrew/bashrc
```

Then you're ready!
