# Validation record

September 25, 2026. Apple M2 Ultra, macOS Sonoma, Apple clang 16.

## Current recipe

- Downloaded the upstream libaacs 0.11.1 archive and verified the formula's
  SHA-256 checksum.
- Applied the exact inline patch to a fresh extraction.
- Ran the recipe's bootstrap, configure, and make-install steps, using the
  installed Homebrew build tools and an isolated temporary installation prefix.
- Compiled and ran the formula's public-API smoke test: version 0.11.1, context
  creation, cache configuration, and context cleanup all passed.
- Confirmed that all 27 public AACS exports match the installed stock library.
  The shared-library filename, compatibility version 8.0.0, and current version
  8.2.0 are preserved. The build sets its library ID to its installation prefix.
- Decrypted an 18 MiB sample through the public libaacs API across 12 passes.
  Every pass validated 3,072 units and 98,304 transport-packet sync bytes. The
  final output matched the stock-library reference after normalizing transport
  copy-permission bits. Median throughput excluding warmup was about
  5,018 MiB/s in this run.
- Ruby syntax validation passed.

The first configuration attempt encountered a restricted macOS system query
in the diagnostic sandbox. Repeating configuration outside that sandbox
resolved Libtool's command-length detection and the build completed normally.
No source workaround for that environmental issue was added.

These checks executed the recipe's build commands directly. They do not
constitute a Homebrew-managed installation, package migration test, or a
`brew test` run against an installed tap formula.

## Earlier backend experiment

Independent builds with the same AES changes decrypted the same sample at
roughly 7,023–7,160 MiB/s versus 356–360 MiB/s for stock libgcrypt-backed
builds. Empty and wrong-key controls failed as expected. Build configuration
and run conditions differ from the recipe validation above.

These are preloaded-buffer decryption measurements, excluding drive I/O,
buffer copying, and validation time. They do not predict complete extraction
speed. The dataset uses one CPS unit key without active bus encryption.
Test keys, disc metadata, media samples, and decrypted data are not included
in this repository.

## Still to validate

- A Homebrew-managed installation and the formula test under Homebrew.
- Replacement of core libaacs, updates, dependency interactions, and restoration.
- The application's existing library loading and complete user workflows.
- Intel Macs, additional macOS versions, multiple CPS keys, and bus encryption.
- Bottle building and distribution, if prebuilt packages are added.
