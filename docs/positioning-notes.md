# Positioning Notes

## Core Positioning

This repo is strongest as a proof point for one argument:

React on Rails Pro is a credible option when a Rails app needs modern React rendering and interactivity on a page that still benefits from Rails ownership of routing, sessions, persistence, redirects, and caching.

## Portfolio Fit

Octochangelog is now best understood as one part of a broader demo set:

- `react_on_rails-demo-octochangelog-on-rails-pro`
  best for public, server-heavy compare/search pages with a tiny client control surface
- `react_on_rails-demo-atomic-crm`
  best for internal SaaS/product workflow pages with linked records and one explicit client island
- `react_on_rails-hacker-news-app`
  best for read-heavy feeds, nested comments, and a Next.js-style streaming mental model
- `gumroad-rsc`
  best for "can we justify a bounded RSC slice inside an existing large Rails app?" discussions

That makes Octochangelog the strongest answer when the conversation is about:

- externally sourced data
- search and comparison flows
- markdown-heavy or documentation-like rendering
- a page where the browser should mostly stay out of the way

## Good Audiences

- Rails teams that want React on selected high-value surfaces without moving application ownership into a JavaScript framework
- teams comparing Rails + RSC to Next.js for data-heavy read surfaces
- teams comparing Rails + React on Rails Pro to Inertia for pages with clearer server/client boundaries
- prospects that need a concrete demo, not just a framework feature list

## Good Page Shapes For This Pitch

- comparison pages
- reporting and analytics surfaces
- documentation views with rich server-rendered content
- search/filter pages with small interactive controls
- pages that pull from external APIs and then perform nontrivial server-side formatting

By contrast, if the prospect wants to see a product-shaped back-office screen with linked record
pages and a bounded workflow island, Atomic CRM is now the better companion demo.

## Why This Demo Works

- The value is legible immediately.
  The page obviously has two different concerns: interactive controls and heavy rendered output.
- The Rails ownership story is concrete.
  The repo uses Rails routes, controllers, sessions, OAuth callbacks, persistence, and CI.
- The RSC benefit is concrete.
  Release-note parsing and grouping stay server-side.
- The client-island story is concrete.
  The form hydrates, but the results zone does not become a giant client app.

## Strong Claims This Repo Supports

- Rails and React 19 RSC can coexist without turning Rails into a thin API shell.
- React on Rails Pro can keep the browser payload focused on the code that truly needs interactivity.
- RSC is especially compelling when the page has expensive server-side composition work.
- React on Rails Pro gives a migration path that is narrower and more Rails-native than a whole-app framework replacement.

## Claims This Repo Does Not Support Well

- that every Rails page should move to React Server Components
- that React on Rails Pro is automatically faster for all page types
- that this repo proves anything definitive about large write-heavy product workflows
- that this demo alone answers deployment, scaling, or hosting decisions

## Comparison Frame Versus Next.js

The useful comparison is not "Can Rails behave exactly like Next.js?"

The useful comparison is:

- Can Rails remain the request shell?
- Can React 19 RSC still give us modern rendering patterns?
- Can we keep the interactive surface small?
- Can we avoid moving auth/session/routing/caching ownership out of Rails?

For this page shape, the answer is yes.

## Comparison Frame Versus Inertia

The useful comparison is not "Is Inertia bad?"

The useful comparison is:

- When the page is heavily React-shaped, does a more explicit React-first rendering model help?
- When the page has expensive server/client composition, is RSC a better fit than a larger client-rendered surface?

This repo argues that the answer can be yes on the right surface.
