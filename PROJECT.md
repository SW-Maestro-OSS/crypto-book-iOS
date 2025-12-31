# Crypto Book iOS – Project Specification

## Architecture
- Platform: iOS / SwiftUI
- State Management: TCA (MVI)
- Feature-oriented modular structure:
  - State / Action / Reducer / View / Dependency

## Core Principles
- All business logic in Reducers
- Side-effects via Effect / Dependency only
- View is stateless and declarative
- Feature isolation preferred over global state

## Features

### Splash
- Show only on first launch
- Minimum display time: 2 seconds
- Preload:
  - Top 30 coins
  - Coin icons
  - Exchange rate (USD → KRW)
  - User settings
- After completion → Market(Home)

### Market (Home)
- Data source: Binance All Market Tickers
- Display top 30 by volume (initial 10 → load more)
- Sortable columns:
  - Symbol
  - Price
  - 24h Change
- Sorting toggles asc/desc on tap
- Coin tap → Currency Detail
- Tabs: Market / Settings

### Currency Detail
- Current price & 24h change
- 7-day candlestick chart
- News from Cryptopanic (external browser)
- AI Insight (buy/sell ratio + brief explanation)

### Settings
- Price Unit: USD | KRW (applies exchange rate)
- Language: English | Korean (live update)

## APIs
- Binance Tickers
- Binance Kline (7-day)
- Cryptopanic News
- KRW Exchange Rate API

## Git Commit Conventions
- Format: `<type>: <summary>`
- Types: feat, fix, refactor, chore, docs, test, style, perf
- Title: English, imperative, <50 chars, no period
- Body optional when necessary
