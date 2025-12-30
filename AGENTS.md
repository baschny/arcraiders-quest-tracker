# AGENTS.md - Quest Tracker Maintenance Guide

This document explains how to maintain and update the ARC Raiders Quest Tracker application.

## Overview

The quest tracker is a modern web application built with Vite, React, TypeScript, and SCSS. It visualizes quest dependencies using React Flow with Dagre layout. Quest data is loaded dynamically from a JSON file.

## Project Structure

```
quest-tracker/
├── src/
│   ├── components/         # React components
│   │   ├── QuestTracker.tsx  # Main application logic
│   │   ├── QuestNode.tsx     # Quest node component
│   │   ├── MapNode.tsx       # Map prerequisite node
│   │   ├── Header.tsx        # Header with logo
│   │   └── Sidebar.tsx       # Stats and search sidebar
│   ├── styles/             # SCSS modules
│   │   ├── main.scss         # Main stylesheet (imports all)
│   │   ├── _variables.scss   # SCSS variables
│   │   ├── _base.scss        # Global styles
│   │   ├── _quest-node.scss  # Quest node styles
│   │   ├── _map-node.scss    # Map node styles
│   │   ├── _sidebar.scss     # Sidebar styles
│   │   └── _react-flow.scss  # ReactFlow overrides
│   ├── utils/              # Utility functions
│   │   ├── helpers.ts        # General helpers
│   │   └── questHelpers.ts   # Quest logic helpers
│   ├── data/               # Static data
│   │   └── static-data.ts    # MAP_NODES, TRADER_IMAGES, etc.
│   ├── types/              # TypeScript types
│   │   └── quest.ts          # Quest interfaces
│   ├── App.tsx             # Root component with data loading
│   ├── main.tsx            # Application entry point
│   └── vite-env.d.ts       # Vite environment types
├── public/                 # Static assets
│   ├── images/             # Images (logo, maps, traders)
│   └── quest-data.json     # Generated quest data
├── dist/                   # Build output (gitignored)
├── index.html              # HTML template
├── vite.config.ts          # Vite configuration
├── tsconfig.json           # TypeScript configuration
├── package.json            # NPM dependencies and scripts
└── generate-quest-data.sh  # Quest data generation script
```

## Quest Data Structure

Quest data comes from `../arcraiders-data/quests/*.json` files. Each quest has:
- `id`: Unique quest identifier
- `name`: Quest name (English)
- `trader`: NPC who gives the quest
- `map`: Array of map identifiers
- `previousQuestIds`: Array of prerequisite quest IDs
- `nextQuestIds`: Array of subsequent quest IDs
- `hasBlueprint`: Boolean indicating if quest rewards a blueprint

## Development Workflow

### Installation

```bash
npm install
```

### Generate Quest Data

Run the generation script:

```bash
npm run generate-data
# or directly:
./generate-quest-data.sh
```

This script:
1. Extracts quest data from `../arcraiders-data/quests/*.json` files
2. Detects blueprint rewards (items ending with `_blueprint`)
3. Adds map prerequisite references to starting quests
4. Outputs to `public/quest-data.json`
5. Reports statistics: total quests, blueprint count, and blueprint quest IDs

### Development Server

```bash
npm run dev
```

Open http://localhost:5173 and verify:
1. All 72 quests are displayed with correct dependencies
2. Map prerequisite nodes appear with distinct styling (dark blue gradient, map images)
3. Blueprint badges (BP icon) appear on the 4 blueprint quests
4. Quest chains and dependencies flow correctly
5. Available quests sidebar shows unlocked quests
6. Search functionality works

## Map Nodes

Map nodes are custom prerequisite nodes (not from arctracker data) that represent map unlock requirements:

- **map_dam_battleground**: Required for "Picking Up The Pieces" (ss1)
- **map_blue_gate**: Required for "A First Foothold" (ss11)
- **map_stella_montis**: Required for "In My Image" (12_in_my_image)

Map nodes have distinct styling:
- Size: 300x110px (vs quest nodes at 300x140px)
- Dark blue gradient background (#263238 to #37474f)
- No trader icon (displays map preview image instead)
- Map images: `images/Dam_Battlegrounds.png.webp`, `images/Blue_Gate.png.webp`, `images/Stella_Montis.png.webp`
- Transparent 2px borders to maintain alignment with quest nodes

## Key Configuration

### Dagre Layout Settings

In the `getLayoutedElements()` function:

```javascript
dagreGraph.setGraph({ 
  rankdir: 'TB',   // Top to bottom
  nodesep: 50,     // Horizontal space between nodes
  ranksep: 70      // Vertical space between tiers
});
```

### React Flow Settings

```javascript
<ReactFlow
  nodes={nodes}
  edges={edges}
  nodeTypes={nodeTypes}
  fitView
  minZoom={0.3}
  maxZoom={1.5}
  defaultViewport={{ x: 0, y: 0, zoom: 0.5 }}
/>
```

### localStorage Keys

- `arcraiders-quest-progress-reactflow`: Stores completed quest IDs as JSON array

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
  - Available quests: Gold/yellow border (#ffc107, 3px solid)
  - Completed quests: Green checkmark badge, green border (#4caf50)
  - Locked quests: Default styling with gray borders
  - Highlighted quests: Cyan glow pulse animation (2 seconds)
  
- **Progress Tracking**:
  - Saved to localStorage (`arcraiders-quest-progress-reactflow`)
  - Smart completion: auto-complete prerequisites with confirmation dialog
  - Smart uncomplete: auto-uncomplete dependents with confirmation dialog
  - Statistics display: X/72 quests completed
  
- **Blueprint Rewards**:
  - Blueprint badge (BP icon) displays on quests that reward blueprint items
  - Dark blue background with grid overlay pattern
  - Tooltip: "Rewards a Blueprint"
  
- **Sidebar - Available Quests**:
  - Shows all currently available quests (prerequisites met, not completed)
  - Click to center and zoom to quest (zoom: 1.0)
  - Quest count displayed in header
  
- **Sidebar - Search**:
  - Real-time search filtering by quest name
  - Click result to center and zoom to quest
  - Press Enter to jump to first result
  - Found quests briefly highlight with cyan glow
  
- **Tooltips**:
  - Trader icon: Shows full trader name
  - Blueprint badge: "Rewards a Blueprint"
  - Wiki button: "Open in ARC Raiders Wiki (new tab)"
  
- **External Links**:
  - Wiki button opens quest page on arcraiders.wiki in new tab

## Common Tasks

### Adding a New Quest

1. Add the quest JSON file to `../quests/` directory
2. Run `./generate-quest-data.sh` to inject the data into `index.html`
3. Refresh the browser - the new quest will appear automatically
4. Verify the quest appears with correct dependencies and blueprint badge (if applicable)

### Adding a New Map Node

1. Add the map image to `images/` directory (e.g., `New_Map.png.webp`)
2. Add the map node to the `MAP_NODES` array in `index.html`:
   ```javascript
   {id: 'map_new_map', name: 'New Map', trader: 'Map', previousQuestIds: [], nextQuestIds: ['first_quest_id']}
   ```
3. Update the corresponding starting quest's `previousQuestIds` to reference the map node
4. Map nodes should have no prerequisites and point to one or more starting quests

### Changing Quest Dependencies

1. Update the quest JSON file in `../quests/` directory
2. Ensure both `previousQuestIds` and `nextQuestIds` are bidirectionally consistent
3. Run `./generate-quest-data.sh` to inject the updated data into `index.html`
4. Refresh the browser to see the changes

### Adjusting Visual Layout

Modify Dagre layout settings in `getLayoutedElements()`:
- `nodesep`: Horizontal spacing between nodes (default: 50)
- `ranksep`: Vertical spacing between tiers (default: 70)
- `rankdir`: Direction of flow ('TB' for top-to-bottom, 'LR' for left-to-right)

### Adding a New Trader

1. Add trader color to `getTraderColor()` function
2. Add trader icon/initial to trader icon rendering logic
3. Update trader name tooltips

## Key Files

- `src/components/QuestTracker.tsx`: Main application logic with React Flow setup
- `src/components/QuestNode.tsx`: Quest node rendering component
- `src/components/MapNode.tsx`: Map prerequisite node component
- `src/data/static-data.ts`: MAP_NODES, TRADER_IMAGES, BLUEPRINT_QUESTS constants
- `src/styles/_variables.scss`: SCSS variables for theming
- `src/types/quest.ts`: TypeScript type definitions
- `generate-quest-data.sh`: Script to regenerate quest data from JSON files
- `public/quest-data.json`: Generated quest data (loaded at runtime)
- `public/images/`: Map and trader images
- `index.html.reactflow.backup`: Backup of old single-file implementation

## Data Flow

```
../arcraiders-data/quests/*.json (source files)
       ↓
./generate-quest-data.sh (extraction script)
       ↓
public/quest-data.json (generated data with hasBlueprint flags)
       ↓
[Loaded by App.tsx via fetch]
       ↓
Combined with MAP_NODES from static-data.ts
       ↓
Passed to QuestTracker component
```

## Notes

- Map nodes are custom prerequisites (not from arctraiders-data JSON files)
- Map nodes must be added manually to `MAP_NODES` array in `index.html`
- Always verify quest dependencies are bidirectional (if A→B, then B should list A in previousQuestIds)
- The application is completely client-side with no external dependencies at runtime (uses CDN for React/React Flow)
- Blueprint detection: Any quest with a reward item ending in `_blueprint` is flagged
- Quest IDs exclude map nodes (72 actual quests, 3 map nodes = 75 total nodes)
