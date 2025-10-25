<!--
  ZCOIN Launchpad — README.md
  Branding: site=https://0xzerebro.io • X/Twitter=@zCoinfdn
  Nerfed/Redacted: external RPC, program IDs, secrets, and file paths are templated.
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
  <a href="https://0xzerebro.io"><img src="https://img.shields.io/badge/Website-0xzerebro.io-blue" alt="site"></a>
  <a href="https://x.com/zCoinfdn"><img src="https://img.shields.io/badge/X-@zCoinfdn-black?logo=x" alt="x"></a>
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

> **Branding:** All references updated to **ZCOIN Launchpad / ZCOIN**. Public links point to **https://0xzerebro.io** and **https://x.com/zCoinfdn**.

---

## 🏷️ Branding

- Product: **ZCOIN Launchpad**
- Ticker/Examples: **ZCOIN**
- Website: **https://0xzerebro.io**
- X/Twitter: **https://x.com/zCoinfdn**

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

```
.
├── server.js                # This server
├── db.json                  # lowdb storage (auto-created)
├── configs.json             # Quote config mapping (quote => public key)
├── quests2.json             # Quest catalog (fallback)
├── /public
│   └── zcoin.png            # Fallback token image
├── /uploads                 # Multer temp (local)
└── /vanity                  # Mint vanity keypairs (.json), moved to /vanity/used after consumption
```

> On Render: use `/data/` for persistent volumes (paths are handled in code).

---

## 🔐 Environment Variables

Create a `.env` file:

```ini
# --- Required ---
WALLET_SECRET=<YOUR_SERVER_WALLET_SECRET_BASE58>
PINATA_JWT=<YOUR_PINATA_JWT>

# Optional overrides
PORT=3000
RENDER=false

# Solana RPC (REDACTED HERE)
SOLANA_RPC_URL=<YOUR_SOLANA_MAINNET_RPC_URL>  # e.g., https://<provider>/<key>
```

> The server should use: `new Connection(process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com', 'confirmed')`

---

## ⚙️ Quick Start

```bash
# 1) Install
npm i

# 2) Prepare data dirs (local)
mkdir -p uploads vanity public image_cache
cp path/to/your/zcoin.png public/zcoin.png

# 3) Add configs.json (quote mint configs)
cat > configs.json <<'JSON'
{
  "SOL": "So11111111111111111111111111111111111111112",
  "USDC": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}
JSON

# 4) Add quests2.json (sample)
echo '[]' > quests2.json  # or your real quests

# 5) Run
node server.js
```

Console:
```
ZCOIN Launchpad server running on http://localhost:3000
```

---

## 🔌 REST API (selected)

- Upload: `POST /upload-file` (multipart: `file`, optional `target`)
- Create Pool: `POST /create` (multipart fields + image)
- Sign & Send: `POST /sign-and-send`
- Confirm Creation: `POST /confirm-creation`
- Token Image Proxy: `GET /token-image?url=<http-url>`
- Comments/Nicknames/Leaderboard/Top Tokens/Platform Stats/Historical/Profiles
- Fee Helpers: `POST /quote-fees`, `POST /claim-fees`

---

## 🖼️ Metadata Template (Pinata)

```json
{
  "name": "My ZCOIN",
  "symbol": "ZCOIN",
  "description": "A ZCOIN Launchpad token.",
  "image": "ipfs://<CID>",
  "website": "https://0xzerebro.io",
  "twitter": "https://x.com/zCoinfdn",
  "createdOn": "https://0xzerebro.io"
}
```

---

## 🛡️ Security Notes

- Do not commit `.env`, `vanity/` keys, or real RPC URLs.
- Scope the Pinata JWT to least privilege.
- Add auth/rate limits before production.

---

## © Branding

- Website: **https://0xzerebro.io**
- X/Twitter: **https://x.com/zCoinfdn**
