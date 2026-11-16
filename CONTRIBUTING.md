# Contributing to fletcher

Thank you for your interest in contributing to fletcher! This guide explains how to install Pixi, run Tytanic tests, update the README, build the manual, and edit docstrings.

## Installing Pixi

Fletcher uses [Pixi](https://pixi.sh/) to run project commands and reproducibly install development tools such as [Tytanic](https://github.com/tytanic/tytanic) for testing, [Nushell](https://www.nushell.sh) for scripting, [Typos](https://crates.io/crates/typos) and also Typst itself.

To install Pixi, run:

```sh
curl -fsSL https://pixi.sh/install.sh | bash
```

After installation, you should have access to all the development tools via `pixi run <commands>` or by activating the development environment with

```sh
pixi shell
```

which makes the tools available directly from the command line.


## Running Tytanic Tests

Fletcher uses [Tytanic](https://github.com/tytanic/tytanic) for testing. To run all the tests:

```sh
pixi run test
```

Alternatively, enter the development environment (`pixi shell`) and use `tt` (if Tytanic is not already on your system).

Using Tytanic (see the [official docs](https://tingerrr.github.io/tytanic/)):

- `tt run <test_set>` to run all tests
- `tt update <test_set>` to update test reference images
- Test sets can be specified like so:
	- All tests, e.g., `tt run`.
	- A single test, e.g., `tt run node/shapes`
	- Tests matching glob pattern, e.g., `tt run -e g:node/*`

## Updating the README

The main `README.md` file is generated from `README.typ`.
To update the README, edit `README.typ` and run:
```sh
pixi run readme compile
```
Or to watch for changes while editing:
```sh
pixi run readme watch
```

## Building the manual PDF

To build the manual PDF (takes a while) and exit:

```sh
pixi run manual compile
```

You can also watch for changes and continuously edit with:

```sh
pixi run manual watch
```


## Building the documentation site

To build the static site under `docs/site/`:

```sh
pixi run site compile
```

To run a local webserver and watch for changes:

```sh
pixi run site watch
```

## Additional Notes

- Please ensure all tests pass before submitting a pull request.
- Thank you! 🎈
