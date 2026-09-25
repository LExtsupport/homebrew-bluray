# Validation record

September 25, 2026. Apple M2 Ultra, macOS Sonoma, Apple clang 16.

## Homebrew installation, replacement, and rollback

The published formula was installed through Homebrew as
`lextsupport/bluray/libaacs` 0.11.1_1, replacing the stock core 0.11.1 package.
The formula's `brew test` and `brew linkage --test` both passed. The installed
receipt identifies this tap, the binary imports CommonCrypto's CCCrypt, and
all three standard library paths resolve to its installed keg.

| Check | Stock libaacs 0.11.1 | Installed accelerated formula |
| --- | ---: | ---: |
| Decrypt the same preloaded 18 MiB | 50.541 ms | 2.546 ms |
| Decryption throughput | 356 MiB/s | 7,070 MiB/s |
| Warm application disc scan | 0.898 s | 0.891 s |

The decryption gain is **19.85 times** in this sample (94.96% less decrypt time).
Each library run used 12 passes, excluding warmup from the median. All 3,072
units and 98,304 packet sync bytes validated on every pass; full normalized
plaintext matched the reference.

The app scans used its existing headless scan command, with one warmup followed
by two timed scans. The results were identical, including all nine detected
audio streams. Scan time was effectively unchanged: this metadata/cache work
is not a measure of bulk decryption or full extraction performance.

The unmodified application's menu diagnostic selected the existing
`/opt/homebrew/opt/libaacs/lib/libaacs.0.dylib` path, reported AACS handled with
error code zero, and read the encrypted disc's menu data with no read/decryption
failure. No app source, binary, or library search paths were changed.

Homebrew's build timings were 14 seconds for libaacs and 1 minute 55 seconds for
libgcrypt. Dependency installation updated Automake to 1.19, Libtool to 2.6.2,
and libgcrypt to 1.12.4, and reinstalled libgpg-error 1.61. The original uninstall
automatically removed unused crypto dependencies. The README now uses
`HOMEBREW_NO_AUTOREMOVE=1` when switching providers to preserve dependencies
between package removal and installation.

Rollback to current core libaacs 0.12.0 succeeded. Its public API decrypted the
same sample correctly at 50.208 ms. Finally, the original core 0.11.1 package
was restored through Homebrew from a local recovery archive, with identical
library bytes and the original paths; it passed decryption again at 49.713 ms.
This final check used the updated libgcrypt dependency and confirms that the
large speed gain comes from the accelerated build. Dependency updates remain
installed. The final verified rollback order removes the unused tap before
installing core; removing it after core installation triggered a duplicate-name
tap-trust error in this Homebrew version. The test ended with the tap removed
and the original library restored. A normal user rollback installs the current
core release, not a saved historical version.

The standard core package was validated by the independent public-API
harness. This Homebrew installation could not resolve the core formula for
`brew test` without a local core tap; no successful core `brew test` is claimed.
The accelerated formula's own `brew test` did pass.

## Initial direct source build

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

These initial checks executed the build commands directly. The later
Homebrew-managed installation and replacement checks are recorded above.

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

- Future formula upgrades and interactions with Homebrew packages that depend
  on core libaacs. The tested machine had no installed Homebrew dependents.
- Complete extraction/playback workflows beyond the scan and menu checks.
- Intel Macs, additional macOS versions, multiple CPS keys, and bus encryption.
- Bottle building and distribution, if prebuilt packages are added.
