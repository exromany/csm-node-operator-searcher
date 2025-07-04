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
  - Deposit queue slot information retrieval (`getDepositQueueSlots`)
  - Deposit queue batch pagination (`getDepositQueueBatches`)
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

- **Holesky**: `0x4562c3e63c2e586cD1651B958C22F88135aCAd4f`
- **Hoodi**: Configured in `DeployHoodi.s.sol`
- **Mainnet**: Configured in `DeployMainnet.s.sol`

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

## Dependencies

- **Foundry**: Smart contract development framework
- **Just**: Command runner for project tasks
- **forge-std**: Foundry standard library for testing and scripting