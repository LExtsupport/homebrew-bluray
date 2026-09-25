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
no prebuilt bottles. This is not yet a qualified replacement for every Mac
or disc configuration. Intel Macs, additional macOS versions, migration from
Homebrew core, upgrades, and application workflows still need validation.

The formula applies its complete source patch inline and regenerates the
Autotools build scripts using current build tools. See
[VALIDATION.md](VALIDATION.md) for the checks completed so far.

## Installation for evaluation

On a Mac without an existing Homebrew libaacs installation:

```sh
brew install LExtsupport/bluray/libaacs
brew test LExtsupport/bluray/libaacs
```

Homebrew automatically adds this tap for the fully qualified install command.
The package uses the same name as Homebrew core's libaacs; the two packages
cannot be installed side by side. Migration instructions will be added after
replacement and restoration have been tested. Adding the tap alone does not
replace an existing library:

```sh
brew tap LExtsupport/bluray
```

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
