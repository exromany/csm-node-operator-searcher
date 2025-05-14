<p align="center">
  <img src="logo.png" width="120" alt="CSM Logo"/>
</p>
<h1 align="center">Node Operator searcher</h1>

## Intro

The `NodeOperatorSearcher` contract efficiently finds Node Operator IDs by address, using pagination and different search modes (current, proposed, or all addresses). It relies on a `CSModule` contract for Node Operator data. Check [CSM](https://github.com/lidofinance/community-staking-module) for more info

## Getting Started

- Install [Foundry tools](https://book.getfoundry.sh/getting-started/installation)

- Install [Just](https://github.com/casey/just)

- Config environment variables

```bash
cp .env.sample .env
```

Fill vars in the `.env` file with your own values

- Build and test contracts

```bash
just
```

## Deploy to local fork

Deploy contracts to the local fork

```bash
just deploy
```

## Deploy on a chain

The following commands are related to the deployment process:

- Dry run of deploy script to be sure it works as expected

```bash
just deploy-live-dry
```

- Broadcast transactions

> Note: pass `--legacy` arg in case of the following error: `Failed to get EIP-1559 fees`

```bash
just deploy-live
```

After that there should be artifacts in the `./artifacts/latest` directory,
which is might be moved to the particular directory and committed

```bash
mv ./artifacts/latest ./artifacts/$CHAIN
```
