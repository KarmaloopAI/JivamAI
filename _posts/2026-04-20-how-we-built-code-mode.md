---
layout: post
title: "How We Built Code Mode: Deep Reasoning for Developers"
date: 2026-04-20
category: Engineering
excerpt_text: "An inside look at our approach to pairing a clean editor experience with a model that genuinely reasons about your code."
author: Jivam Team
read_time: "7 min read"
thumb_bg: "linear-gradient(135deg, #1a2550 0%, #0e1a3d 100%)"
---

Code Mode started as a question: what does an AI coding interface look like when the underlying model can actually *reason*, not just complete?

Most coding tools built on LLMs are good at pattern matching. They've seen enough code that they can continue a function, suggest a variable name, or fill in a boilerplate block. That's useful. But it breaks down the moment you hit a genuinely hard problem — a subtle bug, an architectural decision, a performance issue that requires holding many constraints in mind at once.

Sarvam-105B is different. It was trained with an emphasis on reasoning chains, and it shows. When you describe a bug in Code Mode, Jivam doesn't guess — it thinks.

## The interface problem

The first prototype of Code Mode looked like a chat interface with syntax highlighting bolted on. It was functional but wrong. Developers don't think about code as a conversation. They think in diffs, in files, in function signatures.

We rebuilt it from scratch around a few principles:

### Diffs, not walls of text

When Jivam suggests a change, it shows you exactly what changed — not a block of code you have to compare against your original. One-click copy for the full block, or line-level copy for specific changes.

### Files as first-class context

You can drag any file into Code Mode. Jivam reads it, references it, and keeps it in context for the session. No more pasting — just drop in your file and describe your problem.

### Focused, not distracted

Code Mode has a different visual register than Conversation Mode — tighter, darker, more like an IDE than a chat interface. The goal is to feel like a natural extension of your existing workflow, not an interruption to it.

## What's next for Code Mode

We're working on deeper integrations: a VS Code extension that can invoke Jivam from your editor, automatic context from your open files, and a diff-review flow for larger changesets.

<div class="callout">
  <strong>Code Mode is available now</strong> on Starter and Pro plans. If you're on the free plan, you can try it for 10 sessions before deciding whether to upgrade.
</div>

<div class="tag-row">
  <span class="tag">Engineering</span>
  <span class="tag">Code Mode</span>
  <span class="tag">Developer Tools</span>
</div>
