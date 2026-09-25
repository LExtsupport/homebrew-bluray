# Third-party notices

The formula packaging is based on the Homebrew libaacs formula, distributed
under the BSD 2-Clause License. Its notice and license are retained in LICENSE.
The source-build compatibility patch for src/devtools/read_file.h is also
carried by Homebrew.

The inline patch modifies VideoLAN libaacs source under LGPL-2.1-or-later.
The upstream source archive retains the original file copyright notices.
In particular, src/libaacs/crypto.c credits:

    Copyright (C) 2009-2010 Obliter0n
    Copyright (C) 2010-2013 npzacs

Changes made by this tap on September 25, 2026 replace the AES-128 ECB encrypt
operation and AACS AES-128 CBC decrypt operation with Apple CommonCrypto.
Other operations continue to use libgcrypt. The complete patch is embedded in
Formula/libaacs.rb. No upstream source files are otherwise vendored here.
