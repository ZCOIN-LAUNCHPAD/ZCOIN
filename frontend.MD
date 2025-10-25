# Frontend Architecture Guide: $zCoin Launchpad

This document provides a detailed overview of the frontend architecture for the **$zCoin Launchpad**. The entire frontend is self-contained within a single `index.html` file, leveraging vanilla HTML, CSS, and JavaScript without any frameworks or build steps.

## Table of Contents

1.  [Overall Philosophy](#1-overall-philosophy)
2.  [File Structure (Internal)](#2-file-structure-internal)
3.  [HTML Structure](#3-html-structure)
4.  [CSS Architecture](#4-css-architecture)
5.  [JavaScript Logic](#5-javascript-logic)
    - [Global State & Initialization](#global-state--initialization)
    - [Single Page Application (SPA) Routing](#single-page-application-spa-routing)
    - [Wallet Management](#wallet-management)
    - [API Interaction](#api-interaction)
    - [DOM Rendering & Manipulation](#dom-rendering--manipulation)
    - [Key Library Integrations](#key-library-integrations)
6.  [Running the Frontend](#6-running-the-frontend)

---

### 1. Overall Philosophy

The frontend is designed for simplicity, performance, and ease of deployment.

-   **Zero Dependencies:** All external libraries (Solana Web3.js, Chart.js) are loaded via CDN, requiring no `npm install` or build process.
-   **Vanilla First:** The application relies entirely on standard web technologies, making it highly portable and easy for any web developer to understand.
-   **Monolithic Structure:** All code (HTML, CSS, JS) resides in one file. While not ideal for massive projects, it simplifies deployment and analysis for this specific application size.
-   **Stateful but Simple:** Application state is managed through global JavaScript variables. UI is updated by re-rendering components when this state changes.

### 2. File Structure (Internal)

The `index.html` file is organized into three main sections:

1.  **`<head>`:**
    -   Basic metadata (`<meta>`, `<title>`).
    -   Font imports from Google Fonts.
    -   CDN links for all JavaScript libraries (`solana/web3.js`, `chart.js`, `jupiter-aggregator`). This is crucial for blockchain and charting functionality.

2.  **`<style>`:**
    -   A single, large `<style>` block contains all the CSS for the application.
    -   It defines the theme, layout, component styles, animations, and responsive media queries.

3.  **`<body>`:**
    -   The main HTML document structure.
    -   Followed by a single, large `<script>` tag containing all the application's JavaScript logic.

### 3. HTML Structure

The `<body>` is structured to support a Single Page Application (SPA) layout with a persistent sidebar and header.

-   **`.sidebar`**: The main navigation element on the left. It contains the logo, navigation buttons (`<button data-view="...">`), and the user's watchlist. It has a `.collapsed` state managed by JavaScript.
-   **`.main-content-wrapper`**: A container that holds the header and the main content area. Its `margin-left` is adjusted when the sidebar collapses.
    -   **`.unified-header`**: The sticky header at the top. It contains the mobile menu button, price tickers, and the wallet connection UI (`#connect`, `#wallet`, etc.).
    -   **`.mobile-menu`**: A hidden navigation menu (`<nav>`) that slides in on mobile devices.
    -   **`<main>`**: The primary content area.
        -   **`.content-view` Sections**: Each "page" of the application is a `<section>` with the class `.content-view` and a unique `id` (e.g., `#dashboard-view`, `#create-view`). JavaScript controls which section has the `.active` class to make it visible.
-   **Modals**: Hidden `<div>` elements with the `.modal` class (e.g., `#walletModal`, `#buyModal`) are used for pop-ups like wallet selection and the Jupiter swap terminal.

### 4. CSS Architecture

The CSS is organized using a component-based approach within a single style block.

-   **CSS Custom Properties (Variables):** The `:root` selector defines a comprehensive set of variables for colors (`--bg-1`, `--accent`), fonts (`--font-main`), spacing, shadows, and radii. This makes theming and consistent styling easy to manage.
-   **Layout System:** The primary layout is built with **Flexbox** and **CSS Grid**.
    -   The main app layout (`.sidebar` + `.main-content-wrapper`) is a simple flex or margin-based system.
    -   Grids are used for component layouts like the token dashboard (`.dashboard-grid`) and forms (`#createForm`).
-   **Component Styles:** CSS rules are grouped logically by the component they style (e.g., `.token-card-v2`, `.sidebar-toggle`, `.unified-header`). This makes it easy to find and modify the styles for a specific UI element.
-   **Responsiveness:** `@media` queries are used extensively to adapt the layout for different screen sizes. Key changes include:
    -   Hiding the sidebar and showing a "hamburger" menu button on mobile.
    -   Stacking grid columns vertically.
    -   Adjusting font sizes and padding for smaller screens.
-   **Animations & Effects:** `@keyframes` are used for:
    -   Loading skeletons (`skel`).
    -   Animated background gradients (`moveGradient`).
    -   Button hover effects and modal fade-ins.
    -   Holographic card effects on hover.

### 5. JavaScript Logic

All client-side functionality is contained within a single `<script>` tag at the end of the `<body>`.

#### Global State & Initialization

-   A set of global variables at the top of the script holds the application's state, including the Solana `connection` object, `userWalletAddress`, `allTokens` data, and various intervals.
-   The `DOMContentLoaded` event listener serves as the entry point, initializing the application by fetching initial data, setting up event listeners, and rendering the default view.

#### Single Page Application (SPA) Routing

-   The core of the SPA is the **`handleViewSwitch(viewId)`** function.
-   When a navigation button is clicked, it calls this function with a `viewId` (e.g., `'dashboard-view'`).
-   This function:
    1.  Clears any `setInterval` timers from the previous view to prevent unnecessary background API calls.
    2.  Removes the `.active` class from all `.content-view` sections.
    3.  Adds the `.active` class to the target section, making it visible.
    4.  Initializes the data fetching and sets up new intervals for the newly activated view (e.g., starts fetching market data on the markets page).

#### Wallet Management

-   **Connection:** The `connectWallet(providerName)` function handles the connection logic. It finds the wallet provider (`window.solana`, `window.solflare`, etc.) in the browser, requests a connection, and updates the UI with the user's wallet address.
-   **Disconnection:** The `disconnect` function logs the user out and resets the UI to its "disconnected" state.
-   **State Updates:** Once connected, the `userWalletAddress` and `connectedProvider` global variables are set, which enables functionality like signing transactions and fetching user-specific data.

#### API Interaction

-   The frontend communicates with a custom backend via the **`fetch` API**.
-   All data fetching is asynchronous, using `async/await` syntax for clean, readable code.
-   **Key Functions:**
    -   `fetchAllTokens()`: Fetches the main list of tokens for the dashboard.
    -   `fetchPlatformStats()`: Retrieves data for the stats page.
    -   `showInsights(mint)`: Fetches detailed data for a single token, including price history and transaction data.
    -   `handleClaimFees()` / Form `submit` listener: These functions `POST` data to the backend to create and process transactions.

#### DOM Rendering & Manipulation

-   The application follows a simple rendering pattern: **Fetch Data → Build HTML String → Set `innerHTML`**.
-   **`buildCard()` & `patchCard()`:** These functions work together. `buildCard` creates a skeleton HTML structure for a token card, and `patchCard` populates it with data. This pattern is used to efficiently update the dashboard.
-   **`renderPage()`:** Renders the correct set of tokens on the dashboard based on the current page and filters.
-   **Event Delegation:** For dynamically created elements (like token cards), event listeners are often attached to a static parent container (e.g., `#launchpadDashboard`). This ensures that clicks on newly added cards are handled without re-attaching listeners every time.

#### Key Library Integrations

-   **Solana Web3.js:** Used primarily for:
    -   Creating the RPC `connection` to the Solana network.
    -   Deserializing transaction data received from the backend into a format the wallet can understand and sign.
    -   Confirming transactions on the blockchain.
-   **Chart.js:** Powers the main price chart on the token insights page, configured with custom gradients and tooltips for a rich user experience.
-   **Jupiter API:** Integrated for two main purposes:
    1.  **Price Feeds:** Fetches real-time prices and 24h change data for the header tickers (SOL, BTC, etc.).
    2.  **Swapping:** The "Buy" modal uses the Jupiter API to get a swap quote and build a transaction, which is then signed and sent by the user's wallet.

### 6. Running the Frontend

Because this is a static, single-file application, there is no build process.

1.  **Backend Requirement:** You must have a backend server running that provides the API endpoints the frontend expects (see `API Endpoints` in the main `README.md`).
2.  **Serving the File:** You can run the `index.html` file using any local HTTP server.
    -   **Using VS Code:** The easiest method is to use the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension. Right-click `index.html` and select "Open with Live Server".
    -   **Using Python:** `python -m http.server`
    -   **Using Node.js:** `npx http-server`

The application will then be accessible in your browser, typically at `http://127.0.0.1:5500`.
