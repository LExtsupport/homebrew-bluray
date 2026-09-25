# Homebrew tap for accelerated macOS libaacs

This tap builds libaacs with Apple CommonCrypto for AES block-key encryption
and payload decryption. The rest of its crypto operations continue to use
libgcrypt. It is an optional external library installation.

The formula remains **`libaacs`**. Its standard Homebrew paths and public API
are preserved, so applications using those paths need no discovery changes:

```text
<Homebrew prefix>/opt/libaacs/lib/libaacs.0.dylib
<Homebrew prefix>/lib/libaacs.0.dylib
<Homebrew prefix>/lib/libaacs.dylib
```

## Status

Initial source recipe, pinned to the tested libaacs 0.11.1 release. There are
no prebuilt bottles. Installation, replacement of Homebrew core's libaacs,
rollback, and the application's existing library paths have been tested on
an Apple M2 Ultra running macOS 14. Intel Macs, additional macOS versions,
upgrades, and broader disc/application workflows still need validation.

The formula applies its complete source patch inline and regenerates the
Autotools build scripts using current build tools. See
[the speed test](VALIDATION.md) for measurements.

## Measured speed improvement

Native decryption was **about 20× faster** than the tested standard Homebrew
build on an Apple M2 Ultra: the same 18 MiB sample took **2.55 ms instead of
50.54 ms**, with matching decrypted output. This measures decryption only;
overall extraction speed also depends on drive speed and other processing.
See [VALIDATION.md](VALIDATION.md) for the test details.

## Installation

### If libaacs is not installed

```sh
brew install LExtsupport/bluray/libaacs
brew test LExtsupport/bluray/libaacs
```

Homebrew automatically adds this tap for the fully qualified install command.

### If standard Homebrew libaacs is already installed

Close applications using libaacs, then run these commands in order:

```sh
brew tap LExtsupport/bluray
brew uninstall libaacs
brew install LExtsupport/bluray/libaacs
brew test LExtsupport/bluray/libaacs
```

Homebrew handles cleanup of unused dependencies and installs the dependencies
needed by the replacement package.

Restart your application afterward. The library name and standard Homebrew
paths stay the same; no application path changes are needed. Adding the tap
alone does not replace an existing library.

If Homebrew refuses to uninstall because another installed formula requires
libaacs, keep the standard package and resolve that dependency first. Do not
force the uninstall. Homebrew core dependencies can require the core provider;
this replacement was tested with no installed Homebrew dependents.

### Switch back to standard Homebrew libaacs

Close applications using libaacs, then run:

```sh
brew uninstall libaacs
brew untap LExtsupport/bluray
brew install libaacs
```

Restart your application. This installs the current standard Homebrew release,
which may be newer than the version you previously had. The tested rollback
installed core libaacs 0.12.0 successfully. Remove the tap before reinstalling
core to avoid a duplicate-formula trust error observed with the tested
Homebrew version.

### Build time

This initial recipe builds from source. On the test M2 Ultra, libaacs built in
**14 seconds**. Building and testing its libgcrypt dependency added **1 minute
55 seconds**; downloads, other dependencies, and machine speed affect the total.
The separate `brew test` command may also install Homebrew's own testing tools
on its first run.

Prebuilt Homebrew bottles are a future packaging step. They would avoid
compiling libaacs on supported Macs; dependencies also need compatible bottles
or an existing installation to avoid their own source builds. A formula inside
a tap is the package type used here. A cask is not needed for prebuilt bottles.

See Homebrew's [tap documentation](https://docs.brew.sh/Taps#duplicate-names)
for duplicate names and dependency limitations.

## Scope

This package only enables hardware acceleration to the native crypto backend. It does not acquire or
distribute disc keys. 

## Sources and licensing

- Upstream: [VideoLAN libaacs](https://www.videolan.org/developers/libaacs.html).
- The formula records the exact upstream source URL and SHA-256. Its inline
  patch contains all changes applied by this tap.
- The libaacs patch is LGPL-2.1-or-later, following the modified upstream
  source; the license text is in [COPYING.LGPL-2.1](COPYING.LGPL-2.1).
- Formula packaging is BSD-2-Clause, based on Homebrew's libaacs recipe.
  See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
