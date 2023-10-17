# MSGPORT

Darwinia Msgport is built upon a flexible and modular architecture, allowing users to harness various cross-chain messaging layers that best suit their specific needs. Msgport provides support for sending arbitrary messages through different low-level cross-chain messaging services.

## Example receiver dApp

Please check [ExampleReceiverDapp](https://github.com/darwinia-network/darwinia-msgport/blob/main/contracts/examples/ExampleReceiverDapp.sol)

## Send message steps

1. Get message line addres.

    a. From the address list part: [Msgport addresses](#msgport-addresses)

    b. From the lineRegistry, please check [Msgport API](https://github.com/darwinia-network/feestimi/blob/main/README.md)

2. Get fee & adapter params [Msgport API](https://github.com/darwinia-network/feestimi/blob/main/README.md)

3. Send message

    - [toChainId: uint256](#msgport-addresses)

    - toDapp: address Your receiver dApp address

    - message: bytes Your message payload

    - params: bytes Adapter params from msgportApi, check step 2

    ```sol
    messageLine.send(toChainId, toDapp, message, params);
    ```

4. You can verify the senderLine and senderDapp address when reciving message

    [Verify example](https://github.com/darwinia-network/darwinia-msgport/blob/main/contracts/examples/ExampleReceiverDapp.sol#L20)

## Msgport addresses

### Testnet

#### Pangolin

chainId: `43`

lineRegistry: `0x123456`

- ORMP line: `0x123456`

#### Arbitrum Goerli

chainId: `421613`

lineRegistry: `0x123456`

- ORMP line: `0x123456`

### Mainnet

## Develop

### Package Manager

[yarn](https://yarnpkg.com/getting-started)

### Foundry

To install dependencies and compile contracts:

```sh
git clone --recurse-submodules https://github.com/darwinia-network/darwinia-msgport.git && cd darwinia-msgport
make tools
yarn install
make
```
