# Callisto-Lords-Multisig

A simple mutisig written in Solidity 0.8.0 compatible with EthereumVM.

The multisig has 2 owners by default.

The multisig allows any owner to propose any Transaction (TX) that would be executed on behalf of this multisig. 

- If all owners **VOTED TO APPROVE** this TX then it is executed immediately
- If at least one of the owners **VOTED TO REJECT** the TX then it can not be executed
- If the TX was proposed and no one voted to REJECT withing 10 days after it was proposed then it can be executed

Owners can be added or removed if ALL EXISTING OWNERS agree to do this.
