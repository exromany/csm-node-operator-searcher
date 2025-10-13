# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Solidity smart contract project implementing a `CSMSatellite` for Lido's Community Staking Module (CSM). The contract provides efficient search and pagination functionality for finding Node Operators by address and querying deposit queue information.

## Core Architecture

### Main Contract: `CSMSatellite.sol`
- **Purpose**: Provides search functionality for Node Operators through the CSM interface
- **Key Features**:
  - Address-based Node Operator search with pagination (`findNodeOperatorsByAddress`)
  - Multiple search modes: current addresses, proposed addresses, or all addresses
  - Deposit queue batch pagination with linked-list traversal (`getDepositQueueBatches`)
- **Dependencies**: Interfaces with `ICSModule` contract for data access

### Interface: `ICSModule.sol`
- Defines the interface to the Community Staking Module
- Contains `NodeOperator` struct with all operator properties
- Defines `Batch` type with bitpacked data (nodeOperatorId, keysCount, next pointer)
- Includes utility functions for unpacking batch data

### Deployment Scripts
- **Base**: `DeployBase.s.sol` - Abstract deployment contract with chain validation
- **Chain-specific**: `DeployHolesky.s.sol`, `DeployHoodi.s.sol`, `DeployMainnet.s.sol`
- Each deployment script inherits from `DeployBase` and configures the CSModule address for the specific chain
- **Chain Selection**: Automatic script selection based on `CHAIN` environment variable

## Development Commands

### Build and Test
```bash
# Default: clean and build
just

# Build contracts
just build

# Clean build artifacts
just clean
```

### Local Development
```bash
# Deploy to local fork (requires Anvil running)
just deploy
```

### Live Deployment
```bash
# Dry run deployment (recommended first)
just deploy-live-dry

# Deploy to live network (requires confirmation)
just deploy-live

# Deploy without confirmation prompt
just deploy-live-no-confirm

# Verify contracts on block explorer
just verify-live
```

## Environment Configuration

The project uses environment variables for configuration:
- `CHAIN`: Target chain (mainnet, holesky, hoodi) - defaults to mainnet
- `RPC_URL`: RPC endpoint for live deployments
- `ANVIL_IP_ADDR`: Anvil host address (defaults to 127.0.0.1)

Create `.env` file from `.env.sample` template before deployment.

## Chain-Specific CSModule Addresses

- **Mainnet** (Chain ID: 1): `0xdA7dE2ECdDfccC6c3AF10108Db212ACBBf9EA83F`
- **Holesky** (Chain ID: 17000): `0x4562c3e63c2e586cD1651B958C22F88135aCAd4f`
- **Hoodi** (Chain ID: 560048): `0x79CEf36D84743222f37765204Bec41E92a93E59d`

## Key Technical Details

### Search Functionality
- Uses pagination to handle large Node Operator sets efficiently
- Supports three search modes for different address types
- Returns array of matching Node Operator IDs within specified range

### Deposit Queue Operations
- Handles linked-list style queue traversal using batch pointers
- Provides both slot-specific and general batch retrieval
- Uses assembly optimization for array trimming

### Deployment Artifacts
- Live deployment artifacts stored in `./artifacts/latest/`
- Chain-specific artifacts moved to `./artifacts/$CHAIN/`
- Transaction records saved in `transactions.json`

## Testing

**Current Status**: The project currently has no custom test files. All testing capabilities are available through Foundry's testing framework, but no project-specific tests have been implemented.

**Testing Framework**: Foundry with forge-std library
**Test Commands**:
```bash
# Run tests (when implemented)
forge test

# Run specific test
forge test --match-test testFunctionName

# Run tests with gas reporting
forge test --gas-report
```

## Dependencies

- **Foundry**: Smart contract development framework
- **Just**: Command runner for project tasks
- **forge-std**: Foundry standard library for testing and scripting
