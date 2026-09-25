# Speed test

Apple M2 Ultra, macOS Sonoma, libaacs 0.11.1. Tested September 25, 2026.

**About 20× faster decryption** compared with the standard Homebrew build.

| Measurement | Standard Homebrew | Accelerated build |
| --- | ---: | ---: |
| Decrypt 18 MiB | 50.54 ms | 2.55 ms |
| Decryption throughput | 356 MiB/s | 7,070 MiB/s |
| Warm app disc scan | 0.898 s | 0.891 s |

The decryption test used the same sample already loaded into memory, taking
the median of 11 passes after one warmup. Both builds produced matching output.
Drive reads were not timed, so the 20× result does not represent whole-disc
extraction speed. The app's warm scan time was effectively unchanged.
