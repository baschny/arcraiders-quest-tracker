# AGENTS.md - Quest Tracker Maintenance Guide

This document explains how to maintain and update the ARC Raiders Quest Tracker application.

## Overview

The quest tracker is a single-file HTML application (`index.html`) that visualizes quest dependencies using React Flow with Dagre layout. Quest data is embedded directly in the JavaScript code.

## Quest Data Structure

Quest data comes from the parent directory's `quests/*.json` files. Each quest has:
- `id`: Unique quest identifier
- `name`: Quest name (English)
- `trader`: NPC who gives the quest
- `previousQuestIds`: Array of prerequisite quest IDs
- `nextQuestIds`: Array of subsequent quest IDs

## Updating Quest Data

### Step 1: Extract Fresh Data from JSON Files

From the parent directory, run:

```bash
cd /Users/ernst/Develop/Games/ArcRaiders/arcraiders-data
jq -s 'map({id, name: .name.en, trader, previousQuestIds: (.previousQuestIds // []), nextQuestIds: (.nextQuestIds // [])})' quests/*.json | jq -c .
```

This outputs a compact JSON array of all quests with only the required fields.

### Step 2: Update index.html with Fresh Data

Create a Node.js script to update the quest data:

```javascript
const fs = require('fs');
const html = fs.readFileSync('quest-tracker/index.html', 'utf8');

// Paste the JSON output from Step 1 here
const quests = [/* JSON from jq command */];

// Add map prerequisite nodes (not part of arctracker data)
const maps = [
  {id:'map_dam_battleground', name:'🗺️ Dam Battleground', trader:'Map', previousQuestIds:[], nextQuestIds:['ss1']},
  {id:'map_blue_gate', name:'🗺️ Blue Gate', trader:'Map', previousQuestIds:[], nextQuestIds:['ss11']},
  {id:'map_stella_montis', name:'🗺️ Stella Montis', trader:'Map', previousQuestIds:[], nextQuestIds:['12_in_my_image']}
];

// Update quest dependencies for map prerequisites
quests.forEach(q => {
  if (q.id === 'ss1') q.previousQuestIds = ['map_dam_battleground'];
  if (q.id === 'ss11') q.previousQuestIds = ['map_blue_gate'];
  if (q.id === '12_in_my_image') q.previousQuestIds = ['map_stella_montis'];
});

const allQuests = [...quests];

// Update QUEST_DATA array in index.html
const questDataRegex = /const QUEST_DATA = \[.*?\];/s;
const newHtml = html.replace(questDataRegex, 'const QUEST_DATA = ' + JSON.stringify(allQuests) + ';');
fs.writeFileSync('quest-tracker/index.html', newHtml);
console.log('Updated quest data successfully');
```

Save this as `/tmp/update_quests.js` and run: `node /tmp/update_quests.js`

### Step 3: Verify the Update

Open `index.html` in a browser and verify:
1. All quests are displayed
2. Map nodes appear at the top with different styling (smaller, darker)
3. Dependencies are correct
4. Quest chains flow properly

## Map Nodes

Map nodes are custom prerequisite nodes (not from arctracker data) that represent map unlock requirements:

- **map_dam_battleground**: Required for "Picking Up The Pieces" (ss1)
- **map_blue_gate**: Required for "A First Foothold" (ss11)
- **map_stella_montis**: Required for "In My Image" (12_in_my_image)

Map nodes have distinct styling:
- Smaller size (200x60 vs 250x80)
- Darker background (#1a1a1a)
- Gray border (#455a64, 3px)
- Bold font
- 🗺️ emoji prefix

## Key Configuration

### Quest Priorities

In `initGraph()`, quest priorities control horizontal positioning (lower = further left):

```javascript
const questPriorities = {
    // Map nodes at the very top/left
    'map_dam_battleground': -2000,
    'map_blue_gate': -2000,
    'map_stella_montis': -2000,
    // Far left: A First Foothold chain
    'ss11': -1000,
    'ss11a': -1000,
    'ss11bx': -1000,
    // Also prioritize ss10x20 which connects to ss11bx
    'ss10x20': -900,
};
```

### Dagre Layout Settings

```javascript
layout: {
    name: 'dagre',
    rankDir: 'TB',  // Top to bottom
    nodeSep: 80,    // Horizontal space between nodes
    rankSep: 100,   // Vertical space between tiers
    padding: 30,
    ranker: 'network-simplex',  // Layout algorithm
    align: 'UL',    // Align nodes to upper-left
}
```

## Trader Colors

Defined in `getTraderColor()`:
- Celeste: `#7b1fa2` (purple)
- Shani: `#f57c00` (orange)
- Lance: `#388e3c` (green)
- Tian Wen: `#c62828` (red)
- Apollo: `#0277bd` (blue)
- Map: `#455a64` (gray)

## Features

- **Visual States**:
  - Available quests: Gold border (#ffd700)
  - Completed quests: Green background (#1b4d2b) and border (#2e7d4e)
  - Locked quests: Default gray styling
  
- **Progress Tracking**:
  - Saved to localStorage (`arcraiders-quest-progress`)
  - Auto-complete prerequisites when marking a quest complete
  - Auto-uncomplete dependents when unmarking a quest
  
- **Zoom Controls**:
  - Focus on available quests (shows context)
  - Zoom in/out
  - Fit all
  - Minimum zoom constraint (can't zoom out past fit level)

- **Wiki Links**: Right-click nodes to open quest wiki page

## Common Tasks

### Adding a New Map Node

1. Add to the `maps` array in the update script
2. Update the corresponding quest's `previousQuestIds`
3. Add priority in `questPriorities` (use -2000 for maps)
4. Update `getTraderColor()` if using a new trader type

### Changing Quest Dependencies

Modify the quest data in Step 2 of the update process, ensuring both `previousQuestIds` and `nextQuestIds` are bidirectionally consistent.

### Adjusting Visual Layout

Modify quest priorities or Dagre layout settings to control node positioning. Lower priorities move nodes left, higher `rankSep` increases vertical spacing.

## Files

- `index.html`: Main application (single file, self-contained)
- `README.md`: User documentation
- `AGENTS.md`: This file (maintenance guide for AI agents)
- `index.html.backup`: Backup of previous version (created during updates)

## Notes

- Map nodes must be added AFTER loading quest data from JSON files
- Map nodes are not part of the arctraiders-data repository
- Always verify quest dependencies are bidirectional (if A→B, then B should list A in previousQuestIds)
- The application is completely client-side with no external dependencies at runtime
