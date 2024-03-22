Shared Libraries
================

## cmusicaiconsensus

The purpose of this library is to make the verification functionality that is critical to CMS's consensus available to other applications, e.g. to language bindings.

### API

The interface is defined in the C header `cmusicaiconsensus.h` located in  `src/script/cmusicaiconsensus.h`.

#### Version

`cmusicaiconsensus_version` returns an `unsigned int` with the API version *(currently at an experimental `0`)*.

#### Script Validation

`cmusicaiconsensus_verify_script` returns an `int` with the status of the verification. It will be `1` if the input script correctly spends the previous output `scriptPubKey`.

##### Parameters
- `const unsigned char *scriptPubKey` - The previous output script that encumbers spending.
- `unsigned int scriptPubKeyLen` - The number of bytes for the `scriptPubKey`.
- `const unsigned char *txTo` - The transaction with the input that is spending the previous output.
- `unsigned int txToLen` - The number of bytes for the `txTo`.
- `unsigned int nIn` - The index of the input in `txTo` that spends the `scriptPubKey`.
- `unsigned int flags` - The script validation flags *(see below)*.
- `cmusicaiconsensus_error* err` - Will have the error/success code for the operation *(see below)*.

##### Script Flags
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_NONE`
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_P2SH` - Evaluate P2SH ([BIP16](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki)) subscripts
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_DERSIG` - Enforce strict DER ([BIP66](https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki)) compliance
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_NULLDUMMY` - Enforce NULLDUMMY ([BIP147](https://github.com/bitcoin/bips/blob/master/bip-0147.mediawiki))
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_CHECKLOCKTIMEVERIFY` - Enable CHECKLOCKTIMEVERIFY ([BIP65](https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki))
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_CHECKSEQUENCEVERIFY` - Enable CHECKSEQUENCEVERIFY ([BIP112](https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki))
- `cmusicaiconsensus_SCRIPT_FLAGS_VERIFY_WITNESS` - Enable WITNESS ([BIP141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki))

##### Errors
- `cmusicaiconsensus_ERR_OK` - No errors with input parameters *(see the return value of `cmusicaiconsensus_verify_script` for the verification status)*
- `cmusicaiconsensus_ERR_TX_INDEX` - An invalid index for `txTo`
- `cmusicaiconsensus_ERR_TX_SIZE_MISMATCH` - `txToLen` did not match with the size of `txTo`
- `cmusicaiconsensus_ERR_DESERIALIZE` - An error deserializing `txTo`
- `cmusicaiconsensus_ERR_AMOUNT_REQUIRED` - Input amount is required if WITNESS is used

### Example Implementations
- [NCMUSICAI](https://github.com/NicolasDorier/NCMUSICAI/blob/master/NCMUSICAI/Script.cs#L814) (.NET Bindings)
- [node-libcmusicaiconsensus](https://github.com/bitpay/node-libcmusicaiconsensus) (Node.js Bindings)
- [java-libcmusicaiconsensus](https://github.com/dexX7/java-libcmusicaiconsensus) (Java Bindings)
- [cmusicaiconsensus-php](https://github.com/Bit-Wasp/cmusicaiconsensus-php) (PHP Bindings)
