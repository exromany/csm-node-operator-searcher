<p align="center">
  <img src="logo.png" width="120" alt="CSM Logo"/>
</p>
<h1 align="center">CSM Satellite</h1>

## Overview

The `CSMSatellite` contract provides efficient search and pagination functionality for Lido's Community Staking Module (CSM). It enables finding Node Operators by address and querying deposit queue information through optimized search algorithms.

### Key Features

- **Address-based Node Operator search** with pagination support
- **Multiple search modes**: current addresses, proposed addresses, or all addresses
- **Deposit queue batch pagination** for efficient queue traversal
- **Cross-chain deployment** support for Mainnet, Holesky, and Hoodi testnet

## Architecture

### Core Components

- **`CSMSatellite.sol`** - Main contract providing search functionality
- **`ICSModule.sol`** - Interface to the Community Staking Module
- **Deployment Scripts** - Chain-specific deployment configurations

### Supported Networks

- **Mainnet** (Chain ID: 1): `0x60B50eaa3f7A0a9169E84Be1E66F51407e2B0Fc7`
- **Hoodi** (Chain ID: 560048): `0x0124A201F2C867Aa40121c4Ac1b7E0C80baB2935`

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) - Smart contract development framework
- [Just](https://github.com/casey/just) - Command runner

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   forge install
   ```

3. Configure environment variables:
   ```bash
   cp .env.sample .env
   ```
   Fill in the required variables in the `.env` file

4. Build contracts:
   ```bash
   just
   ```

## Development

### Available Commands

```bash
# Build and clean (default)
just

# Build contracts only
just build

# Clean build artifacts
just clean

# Deploy to local fork (requires Anvil)
just deploy

# Dry run deployment
just deploy-live-dry

# Deploy to live network
just deploy-live

# Deploy without confirmation
just deploy-live-no-confirm

# Verify contracts on block explorer
just verify-live
```

### Environment Configuration

Set these environment variables in your `.env` file:

- `CHAIN` - Target chain (mainnet, holesky, hoodi) - defaults to mainnet
- `RPC_URL` - RPC endpoint for live deployments
- `ANVIL_IP_ADDR` - Anvil host address (defaults to 127.0.0.1)

### Chain Selection

The deployment script is automatically selected based on the `CHAIN` environment variable:
- `mainnet` → `DeployMainnet.s.sol`
- `holesky` → `DeployHolesky.s.sol`
- `hoodi` → `DeployHoodi.s.sol`

## Deployment

### Local Development

1. Start Anvil:
   ```bash
   anvil
   ```

2. Deploy to local fork:
   ```bash
   just deploy
   ```

### Live Network Deployment

1. Set up your environment variables in `.env`

2. Run dry deployment to verify:
   ```bash
   just deploy-live-dry
   ```

3. Deploy to live network:
   ```bash
   just deploy-live
   ```

4. Move deployment artifacts:
   ```bash
   mv ./artifacts/latest ./artifacts/$CHAIN
   ```

### Deployment Artifacts

- Live deployment artifacts are stored in `./artifacts/latest/`
- Chain-specific artifacts should be moved to `./artifacts/$CHAIN/`
- Transaction records are saved in `transactions.json`

## Testing

The project uses Foundry's testing framework. Currently, no custom tests are implemented.

```bash
# Run tests (when implemented)
forge test

# Run specific test
forge test --match-test testFunctionName

# Run tests with gas reporting
forge test --gas-report
```

## Documentation

For detailed technical documentation and development guidelines, see [CLAUDE.md](./CLAUDE.md).

## Related Projects

- [Community Staking Module](https://github.com/lidofinance/community-staking-module) - Main CSM implementation

## License

This project is licensed under the terms specified in the [LICENSE](./LICENSE) file.
