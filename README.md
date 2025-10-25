cat > README.md <<'EOF'
<!--
  ZCOIN Launchpad — README.md
  Nerfed / Redacted: external RPC, program IDs, secrets, and file paths are templated.
-->

<p align="center">
  <img src="https://img.shields.io/badge/ZCOIN%20Launchpad-online-brightgreen?logo=solana" alt="status">
  <img src="https://img.shields.io/badge/Node.js-18%2B-026e00?logo=node.js&logoColor=white" alt="node">
  <img src="https://img.shields.io/badge/Express-4.x-black?logo=express" alt="express">
  <img src="https://img.shields.io/badge/Pinata-IPFS-blue?logo=pinboard" alt="pinata">
  <img src="https://img.shields.io/badge/Solana-Web3-purple?logo=solana" alt="solana">
</p>

<h1 align="center">🚀 ZCOIN Launchpad — Server</h1>

<p align="center">
  A lightweight Node/Express backend for creating virtual token pools on Solana using
  Meteora DBC, uploading assets to IPFS via Pinata, caching images, live token chat via WebSockets,
  on-chain trade ingestion (Jupiter Data API), quests/points, leaderboards, and fee-claim helpers.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-informational" alt="license">
  <img src="https://img.shields.io/badge/Database-lowdb-lightgrey" alt="lowdb">
  <img src="https://img.shields.io/badge/WebSockets-ws-ff69b4" alt="ws">
</p>

---

## 🔰 TL;DR

- `POST /create` — build a new pool (and optional first buy), assets pinned to IPFS, returns a **base64 tx** for the client to sign.
- `POST /sign-and-send` — server partially signs with the **mint vanity keypair**, broadcasts to Solana, returns **signature**.
- `POST /confirm-creation` — verifies tx, extracts pool address, **indexes token** in lowdb, awards quests.
- Realtime chat: WebSocket channels per-token.
- Stats/feeds: platform stats, top tokens, historical charts, holders, leaderboard, bounties, comments, nicknames.
- **Nerfed/Redacted** bits are templated like "<YOUR_...>". Replace with your real values.

> **Branding:** All references updated to **ZCOIN Launchpad / ZCOIN**.

---

## 🏷️ Branding

- Product: **ZCOIN Launchpad**
- Ticker/Examples: **ZCOIN**
- Default site (example): `https://zcoin.launch/` *(placeholder)*

---

## 🧱 Features

- ⚙️ **Pool Creation** via Meteora Dynamic Bonding Curve SDK
- 🖼️ **IPFS Uploads** (Pinata) for token image + metadata JSON
- 🗃️ **lowdb** JSON storage (tokens, trades, wallets, quests, comments)
- 💬 **Realtime Chat** per-token room (WebSockets)
- 📈 **Trade Ingestion** from Jupiter Data API
- 🏆 **Quests & Points** engine (volume-based, flips, snipes, launches)
- 🧑‍🤝‍🧑 **Nicknames, Comments, Leaderboard**
- 🖼️ **Image Cache** proxy with disk caching
- 🧮 **Platform Stats** + **Historical Stats**
- 💸 **Fee Quote & Claim** helpers for DBC pools
- 🔁 **Auto-Migration** status checker (marks pools as graduated)

---

## 📦 Requirements

- Node.js **18+**
- A Solana mainnet RPC endpoint
- A funded wallet secret key (Base58) for server-side signing of the mint (vanity) when finalizing tx
- Pinata JWT for IPFS uploads

---

## 🗂️ File Structure (excerpt)

