# SPEC.md - ARC Raiders Quest Tracker Technical Specification

## Overview

The ARC Raiders Quest Tracker is a single-file web application that provides an interactive visual representation of quest dependencies in the ARC Raiders game. It allows users to track their quest completion progress with automatic dependency resolution and persistent storage.

**Type**: Client-side web application  
**Technology**: Pure HTML/JavaScript with Cytoscape.js graph visualization  
**Storage**: Browser localStorage  
**Deployment**: Static HTML file (no server required)

## Core Functionality

### Quest Visualization

The application displays quests as a directed acyclic graph (DAG) using the Cytoscape.js library with Dagre layout algorithm. Each quest is represented as a node, and quest dependencies are shown as directional edges.

**Layout Configuration**:
- Direction: Top-to-bottom (TB)
- Node spacing: 80px horizontal, 100px vertical
- Layout algorithm: Dagre network-simplex
- Alignment: Upper-left (UL)

**Visual States**:
1. **Available Quest**: Gold border (#ffd700, 3px width) - quest whose prerequisites are all completed
2. **Completed Quest**: Green background (#1b4d2b) with green border (#2e7d4e, 3px width)
3. **Locked Quest**: Default gray styling - prerequisites not yet met
4. **Hover State**: Slightly lighter background (#3c3c3c) on mouseover

**Node Styling**:
- Standard quest nodes: 250x90px rounded rectangles
- Display format: `(quest_id)` on first line, quest name in bold (14px font)
- Text wrapping enabled with max width 220px
- Font: Segoe UI (or system fallback)

**Edge Styling**:
- Base edges: 2px width, gray (#555)
- Completed paths: 2.5px width, green (#2e7d4e)
- Available paths: 2.5px width, lighter gray (#888)
- Arrow heads: triangles, scaled 1.5x
- Curve style: Bezier

### Quest Data Structure

Quest data is sourced from the parent directory's `quests/*.json` files. Each quest object contains:

```javascript
{
  id: string,              // Unique quest identifier
  name: string,            // Quest name (English)
  trader: string,          // NPC trader (Celeste, Shani, Lance, Tian Wen, Apollo)
  previousQuestIds: [],    // Array of prerequisite quest IDs
  nextQuestIds: []         // Array of subsequent quest IDs
}
```

**Total Quest Count**: 72 quests (as of current data)

**Trader Color Coding**:
- Celeste: Purple (#7b1fa2)
- Shani: Orange (#f57c00)
- Lance: Green (#388e3c)
- Tian Wen: Red (#c62828)
- Apollo: Blue (#0277bd)

### Progress Tracking

**Storage**: Browser localStorage key `arcraiders-quest-progress`  
**Format**: JSON array of completed quest IDs

**Completion Behavior**:
- Clicking an available/locked quest marks it as complete
- Automatically marks all prerequisite quests as complete
- Warns user if marking a quest will auto-complete multiple prerequisites
- Progress saved immediately to localStorage

**Uncompletion Behavior**:
- Clicking a completed quest unmarks it
- Automatically unmarks all dependent quests (cascading effect)
- Warns user if unmarking will affect any dependent quests
- Recursive dependency resolution ensures graph consistency

**Confirmation Dialogs**:
- When completing a quest with N prerequisites: "Marking [quest] as complete will also mark N prerequisite quest(s) as complete. Continue?"
- When uncompleting a quest with N dependents: "Unmarking [quest] will also unmark N dependent quest(s). Continue?"

### Navigation and Zoom Controls

**Initial State**:
- Zoom level: 90% (0.9)
- Position: Centered on topmost available quest
- Minimum zoom: Fit-all level (dynamically calculated, typically ~12%)
- Maximum zoom: 200% (2.0)

**Zoom Controls**:
1. **Zoom Slider**: Bottom-right corner control
   - Range: 30-200% (0.3-2.0)
   - Visual display: Shows current percentage
   - Interactive: Click/drag to adjust zoom
   - Style: Dark background (#2c2c2c) with cyan slider (#4fc3f7)

2. **Shift + Wheel**: Zoom in/out
   - Sensitivity: ±3% per scroll increment
   - Zooms relative to mouse cursor position
   - Constrained to min/max bounds

3. **Buttons**:
   - Zoom In (+): Increases zoom by 20%
   - Zoom Out (-): Decreases zoom by 20%, respects minimum
   - Fit All: Fits entire graph to viewport

**Pan Controls**:
- **Mouse Wheel / Magic Mouse**: Pan vertically and horizontally
- **Trackpad**: Two-finger drag to pan
- Delta values directly map to pan offset

**Focus Controls**:
- **Focus Top Available**: Centers view on the topmost available quest (by Y position)
  - Maintains current zoom level
  - Does nothing if no available quests exist

**Interaction Specifics**:
- Cytoscape's default wheel zoom is disabled (`userZoomingEnabled: false`)
- Custom wheel handler with capture phase to intercept all wheel events
- Events on zoom control are blocked from propagating to graph
- Node dragging disabled (`autoungrabify: true`)
- Box selection disabled

### Quest Interaction

**Click (Tap)**:
- Toggles quest completion status
- Triggers automatic dependency resolution
- Shows confirmation dialogs when needed
- Updates graph and statistics immediately

**Right-Click (Context Menu)**:
- Opens quest wiki page in new tab
- Wiki URL format: `https://arcraiders.wiki/wiki/{Quest_Name}`
- Quest name is title-cased and spaces replaced with underscores

**Hover**:
- Changes node background to lighter shade
- Visual feedback for interactive elements

## User Interface

### Layout Structure

```
┌─────────────────────────────────────────┐
│ ARC Raiders Quest Tracker (Title)       │
├─────────────────────────────────────────┤
│ [Progress Controls] [View Controls]     │
├─────────────────────────────────────────┤
│                                         │
│          Quest Graph Container          │
│              (800px height)             │
│                                         │
│         [Zoom Control Overlay]          │
└─────────────────────────────────────────┘
│ ┌────────┬────────────┬────────────┐   │
│ │Complete│  Available │   Total    │   │
│ │   N    │     M      │     72     │   │
│ └────────┴────────────┴────────────┘   │
└─────────────────────────────────────────┘
```

### Control Buttons

**Progress Management**:
- Reset All Progress: Clears all completed quests (with confirmation)

**View Controls**:
- Focus Top Available: Centers on topmost available quest
- Zoom In (+): Increase zoom level
- Zoom Out (-): Decrease zoom level
- Fit All: Fit entire graph to viewport

### Statistics Display

Real-time counters showing:
1. **Completed**: Number of quests marked as complete
2. **Available**: Number of quests currently available to complete
3. **Total Quests**: Total count (72)

Styled with large cyan numbers (#4fc3f7) on dark background.

## Technical Implementation

### Dependencies

**External Libraries** (loaded via CDN):
1. Cytoscape.js v3.28.1 - Graph visualization engine
2. Dagre v0.8.5 - Directed graph layout algorithm
3. Cytoscape-Dagre v2.5.0 - Cytoscape layout adapter for Dagre

**No Build Process Required**: Single HTML file with inline CSS and JavaScript.

### Data Flow

```
JSON Files (../quests/*.json)
    ↓
[Manual Update Process] (jq command)
    ↓
Embedded QUESTS Array in index.html
    ↓
Cytoscape Graph Elements
    ↓
User Interactions
    ↓
localStorage (persistent state)
```

### Key Algorithms

**Prerequisite Collection** (`getPrerequisiteQuests`):
- Breadth-first search through prerequisite chain
- Collects all incomplete prerequisites
- Returns list including the target quest
- Used when marking a quest complete

**Dependent Unmarking** (`unmarkQuestAndDependents`):
- Recursive depth-first unmarking
- Finds all completed dependents
- Cascades unmarking through dependency tree
- Used when unmarking a quest

**Available Quest Detection** (`isQuestAvailable`):
- Quest is available if:
  - Not already completed, AND
  - Has no prerequisites (root quest), OR
  - All prerequisites are completed

**Top Available Quest** (`centerOnTopAvailable`):
- Filters for available, incomplete quests
- Finds node with minimum Y position (topmost)
- Centers viewport on that node
- Preserves current zoom level

### Quest Priority System

For controlling horizontal positioning in the graph layout:

```javascript
const questPriorities = {
    'ss11': -1000,      // A First Foothold chain (leftmost)
    'ss11a': -1000,
    'ss11bx': -1000,
    'ss10x20': -900,    // Connected to ss11bx
    // Default: 0 (all other quests)
};
```

Lower priority values are placed further left. This minimizes edge crossings and improves readability.

### Browser Compatibility

**Minimum Requirements**:
- Modern browser with ES6 support
- localStorage API
- Canvas API (for Cytoscape rendering)

**Tested On**:
- Chrome/Edge (Chromium-based)
- Safari (macOS)
- Firefox

**Known Compatibility**:
- Magic Mouse scrolling: Fully supported with custom wheel handler
- Trackpad gestures: Zoom (Shift+scroll) and pan (scroll) working
- Touch devices: Basic support (tap to toggle, pinch to zoom)

## File Structure

```
quest-tracker/
├── index.html          # Main application (self-contained)
├── README.md           # User documentation
├── AGENTS.md           # Maintenance guide for AI agents
├── SPEC.md             # This file (technical specification)
└── index.html.backup   # Backup file (created during updates)
```

## Configuration

### Modifiable Parameters

**In `index.html` JavaScript section**:

```javascript
// Zoom settings
const initialZoom = 0.9;              // Initial zoom (90%)
const minZoomStep = 0.97;              // Zoom out step (Shift+wheel)
const maxZoomStep = 1.03;              // Zoom in step (Shift+wheel)
const buttonZoomMultiplier = 1.2;     // Zoom button step (20%)

// Layout settings
const nodeSep = 80;                   // Horizontal node spacing
const rankSep = 100;                  // Vertical tier spacing
const layoutPadding = 30;             // Graph padding

// Visual settings
const nodeWidth = 250;                // Quest node width
const nodeHeight = 90;                // Quest node height (increased for ID display)
const containerHeight = '800px';      // Graph container height
```

### Color Scheme

**Background**: Dark theme (#1a1a1a)  
**Text**: Light gray (#e0e0e0)  
**Accents**: Cyan (#4fc3f7)  
**Interactive Elements**: Dark gray (#2c2c2c) with lighter hover states

## Maintenance

### Updating Quest Data

Follow the procedure in `AGENTS.md`:

1. Extract data from JSON files:
```bash
cd /path/to/arcraiders-data
jq -s 'map({id, name: .name.en, trader, previousQuestIds: (.previousQuestIds // []), nextQuestIds: (.nextQuestIds // [])})' quests/*.json | jq -c .
```

2. Update `QUESTS` array in `index.html` (line ~207)

3. Verify quest dependencies are bidirectional

4. Test in browser before committing

### Adding New Features

**When modifying the graph**:
- Batch Cytoscape operations with `startBatch()` / `endBatch()`
- Update both node data and visual styling
- Ensure graph state synchronizes with localStorage

**When adding new interactions**:
- Stop event propagation for overlays (like zoom control)
- Use `closest()` to check if events target specific elements
- Maintain consistency with existing confirmation dialogs

## Performance Considerations

**Optimization Strategies**:
1. Single file = single HTTP request, instant load
2. Batched graph updates prevent multiple redraws
3. localStorage operations are synchronous but fast (<1ms)
4. No animation effects = no performance overhead
5. Event delegation for efficiency

**Scalability**:
- Current: 72 quests, performs smoothly
- Tested up to: ~100 nodes without noticeable lag
- Layout calculation: <100ms on modern hardware
- Memory footprint: ~5MB (mostly Cytoscape.js)

## Known Limitations

1. **No Multi-User Sync**: Progress is per-browser, not synced across devices
2. **No Export/Import**: No built-in way to backup or transfer progress between browsers/devices
3. **No Undo/Redo**: Quest toggling is immediate, no history tracking
4. **No Search/Filter**: All quests always visible
5. **No Quest Details**: Clicking opens wiki, no in-app detail view
6. **Static Data**: Quest data must be manually updated from JSON files
7. **No Mobile Optimization**: Usable but not optimized for small screens
8. **Wiki Link Accuracy**: Name transformation may not match wiki URL structure for all quests

## Future Enhancement Possibilities

**Potential Features** (not implemented):
- Export/import progress functionality
- Search/filter quests by name or trader
- Show quest details in sidebar/modal
- Highlight specific quest chains
- Mobile-responsive layout
- Dark/light theme toggle
- Export progress as shareable URL
- Quest completion statistics (e.g., quests per trader)
- Keyboard shortcuts for common actions
- Minimap for large graphs
- Animation for completion cascades

## Version History

See git commit history for detailed changes. Key milestones:

- **v1.0** (2024-12): Initial release with core functionality
- **v1.1** (2024-12): Added zoom slider and improved scroll controls
- **v1.2** (2024-12): Quest data update, dependency warning on uncompletion
- **Current** (2024-12): Reduced zoom sensitivity, added centerOnTopAvailable

---

**Last Updated**: December 27, 2024  
**Document Version**: 1.0  
**Application Version**: See git commit hash
