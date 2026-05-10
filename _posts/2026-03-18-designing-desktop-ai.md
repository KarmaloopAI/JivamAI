---
layout: post
title: "Designing a Desktop AI That Doesn't Feel Like a Website"
date: 2026-03-18
category: Design
excerpt_text: "On the principles behind Jivam's native UI — density, speed, and why we chose a sidebar-first layout for conversations."
author: Jivam Team
read_time: "5 min read"
thumb_bg: "linear-gradient(135deg, #1e1535 0%, #130e2a 100%)"
---

The hardest thing about designing Jivam wasn't making it look good. It was making it feel *native*.

Most AI apps are websites wearing the skin of a desktop app. They load slowly, they feel laggy, they don't respond to keyboard shortcuts, they don't integrate with your system. They're useful — but they never disappear into your workflow.

We set out to build something different.

## The density question

Web design tends toward spaciousness. Large type, generous padding, lots of whitespace. That works for marketing pages and long-form content. It doesn't work for a tool you use for hours a day.

Jivam's UI is denser than most AI interfaces. Not cramped — but information-rich. You can see your full conversation history in the sidebar without scrolling. The model response appears at a readable size without taking up the full screen. There's room to think.

## Keyboard first

Every action in Jivam has a keyboard shortcut. `⌘K` opens the command palette. `⌘N` starts a new conversation. `⌘/` jumps to search. You should never need to reach for the mouse.

This is a deliberate choice. Power users — developers, researchers, writers — spend their days in keyboard-centric environments. We wanted Jivam to feel like a natural extension of that, not an interruption.

## The sidebar layout

We tried several layouts before landing on the sidebar-first approach. The key insight: your conversation history is as important as the current conversation. You should be able to jump between threads, find something you discussed last week, and pick up where you left off — all without leaving the flow of the current session.

The sidebar is always visible. It's searchable. It's organised by date. And it updates in real time as responses stream in.

## Dark mode by default

Jivam ships with dark mode on by default. This was a deliberate decision — most of our target users (developers, writers working late, people in office environments with screens) prefer it. Light mode is fully supported and equally polished. But dark mode is the primary experience.

<div class="tag-row">
  <span class="tag">Design</span>
  <span class="tag">UI</span>
  <span class="tag">Desktop</span>
</div>
