# MSGPORT

Darwinia Msgport is built upon a flexible and modular architecture, allowing users to harness various cross-chain messaging layers that best suit their specific needs. Msgport provides support for sending arbitrary messages through different low-level cross-chain messaging services.

## Example receiver dApp

For an example receiver dApp, please refer to the [ExampleReceiverDapp](https://github.com/darwinia-network/darwinia-msgport/blob/main/contracts/examples/ExampleReceiverDapp.sol) file.

## Sending message

1. Obtain the message line addres.

    a. From the address list part: [Supported chains](./SUPPORTED.md)

    or

    b. Through lineRegistry contract: `lineRegistry.getLine(string protocolName)`

    or

    c. Through the sdk, please refer to the [Msgport API](https://github.com/darwinia-network/feestimi/blob/main/README.md) for more information.

2. Retrieve the fee and adapter `params` from the [Msgport API](https://github.com/darwinia-network/feestimi/blob/main/README.md)

3. Send the message using the following parameters

    - toChainId: uint256 - Use the standard EVM chainId. [Supported chains](./SUPPORTED.md)

    - toDapp: address - The address of your receiver dApp.

    - message: bytes - The payload of your message.

    - params: bytes - Adapter params obtained from the Msgport API in step 2.

    ```sol
    messageLine.send(toChainId, toDapp, message, params);
    ```

4. You can verify the senderLine and senderDapp addresses when reciving the message.

    For an example, please check [Verify example](https://github.com/darwinia-network/darwinia-msgport/blob/main/contracts/examples/ExampleReceiverDapp.sol#L20)

## Develop

### Foundry

To install dependencies and compile contracts:

```sh
git clone --recurse-submodules https://github.com/darwinia-network/darwinia-msgport.git && cd darwinia-msgport
make tools
yarn install
make
```
