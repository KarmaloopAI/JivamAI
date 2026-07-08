---
layout: post
title: "Rebuilding Jivam's Desktop App From the Ground Up"
date: 2026-07-08
category: Engineering
excerpt_text: "We tore out Electron and rebuilt Jivam's desktop app as a lightweight local server with a native install flow. Here's why, and what changed for you."
author: Jivam Team
read_time: "6 min read"
thumb_bg: "linear-gradient(135deg, #1c2a4a 0%, #0d1530 100%)"
---

For the first several months of Jivam's life, the desktop app was an Electron app — like most desktop AI tools. It worked. It also came with a set of tradeoffs we'd been quietly unhappy with for a while: a large download, a slower startup, and a code-signing bill that scaled with every platform we supported. We've spent the last stretch replacing that foundation entirely, and the app you're installing today is a genuinely different piece of software from the one we shipped a few months ago.

## What Electron was costing us

Electron bundles an entire copy of Chromium into every app. That's why desktop AI tools tend to be 150-200MB downloads for what's fundamentally a chat window. It's also why they take a beat to open — you're not just starting an app, you're booting a browser.

The bigger cost was invisible to users but very visible to us: code-signing certificates for macOS and Windows aren't free, and they don't get cheaper as you ship more platforms. Every new binary we produced was another thing to sign, notarize, and worry about breaking when a certificate expired.

None of this is a criticism of Electron — it's an excellent tool for what it's built for. It just wasn't buying us anything we actually needed.

## The insight: you already have a signed, trusted browser

Every Mac ships with Safari. Every Windows PC ships with Edge. These are already signed, already notarized, already trusted by the OS. So instead of shipping our own browser inside our own app, we asked: what if Jivam just *drove* the browser you already have?

That's the new architecture. `jivam` is a small local server — an Express app plus a WebSocket connection — that runs on your machine and serves Jivam's interface at `localhost:7842`. The interface itself is a React app, same as before. What changed is everything underneath it: no Electron, no bundled Chromium, no IPC layer between a main process and a renderer process. Just a real web app, talking to a real local server, over the same `fetch()` and WebSocket APIs any website uses.

Installing it is one command:

```bash
curl -fsSL https://jivamai.com/install.sh | bash   # macOS / Linux
irm https://jivamai.com/install.ps1 | iex          # Windows
```

That script checks for Node.js (installing it if it's missing), pulls `jivamai` and `jiva-core` straight from npm, and sets Jivam up to run persistently in the background — a macOS LaunchAgent or a Windows Scheduled Task, depending on your platform — so the server is already warm by the time you ever click an icon.

## Getting a real Dock icon without Electron

The one thing Electron did give us for free was a proper, single-instance Dock icon with its own bundle identity. A plain browser tab doesn't have that — and neither does the obvious workaround, `chrome --app=url`, which just opens inside Chrome's own process and bundle ID. Click that "app" window's Dock icon and click Chrome's, and macOS can't tell them apart.

Safari, it turns out, already solves this. Since macOS Sonoma, Safari has a native **File → Add to Dock…** feature that creates a genuinely separate `.app` bundle with its own identity — a real Dock icon, real single-instance behavior, no Electron required. On install, Jivam opens Safari to a plain tab and shows you exactly where to click to finish setting it up as an app. Once you do, that's it — Jivam lives in your Dock like any other native app, and future launches skip the browser chrome entirely.

We deliberately kept this step manual rather than trying to automate the click ourselves. Automating it would have required asking for Accessibility permissions — a heavyweight, easy-to-miss macOS permission prompt — just to save one click, and Safari's final confirmation dialog can't be automated even if you have that permission (Apple treats installing an app as security-sensitive, on purpose). One clearly-signposted click beats a fragile automation that silently falls back to a worse experience when permissions aren't granted in time.

## What this means for you

- **A dramatically smaller footprint.** No bundled Chromium, no per-platform binary — Jivam is a small npm package.
- **Faster startup.** The server runs continuously in the background; opening the app is just opening a window, not booting a runtime.
- **A real Dock icon, the native way** — via Safari's own app-installation feature, not a workaround.
- **Simpler updates.** Jivam checks for new versions in the background and updates itself via the same `npm install -g` path it was installed with — no separate updater process to maintain.

If you installed Jivam a while ago, the next update will carry you across automatically. If you're installing fresh, `jivamai.com/download` walks you through the one-command setup on macOS, Windows, and Linux.

<div class="callout">
  <strong>This isn't a smaller version of the old app.</strong> Everything — Chat, Code Mode, Cowork — is fully intact. What changed is what's running underneath it, not what it can do.
</div>

<div class="tag-row">
  <span class="tag">Engineering</span>
  <span class="tag">Desktop</span>
  <span class="tag">Architecture</span>
</div>
