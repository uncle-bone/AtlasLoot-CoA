# AtlasLoot-CoA v8.1.1 — BiS browser framework

> **[⬇ Download v8.1.6](https://github.com/downingwow/AtlasLoot-CoA/releases/download/v8.1.6/AtlasLoot-CoA-v8.1.6.zip)**


Loot browsing for Ascension Conquest of Azeroth / Conquest Reborn on the WoW 3.3.5a-based client. Retains the supplied Ascension loot tables, item browsing, cache and wishlist settings, and adds the CoA BiS interface framework.

## Current update

- Adds a clickable Best in Slot tab with Phase 1 / Phase 2 selectors, class/spec controls, paged gear rows and in-game item tooltips.
- The phase list data is deliberately empty in this supplied build. This is a browser framework, not a completed collection of best-in-slot recommendations. It displays the missing-data status instead of inventing lists.
- Publishes the complete package: both `AtlasLoot` and the required `AtlasLoot_Cache` companion folder. The latest main-folder update is combined with the Cache folder from the supplied full AtlasLoot package.
- Retains the prior CoA bugfix baseline and existing SavedVariables.

## Installation

Back up existing addon files and WTF/SavedVariables. Extract both addon folders side by side into Interface/AddOns, keeping their names unchanged. Enable both in the character-selection AddOns menu. Use the addon interface to browse loot and open the BiS tab. Future updates should replace the complete package, not just the main folder.

The earlier bugfix baseline was reported to load without errors; the new BiS framework still needs in-game validation and populated, verified lists.

Maintainer: Uncle Bone — https://github.com/downingwow/AtlasLoot-CoA
Original contributors include Hegarol, Skray, Szyler, Anch, Rvng and others credited in the source. GPL v2 and other supplied third-party notices remain applicable.
