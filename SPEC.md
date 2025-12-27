# SPEC.md - ARC Raiders Quest Tracker Technical Specification

## Overview

The ARC Raiders Quest Tracker is a single-file web application that provides an interactive visual representation of quest dependencies in the ARC Raiders game. It allows users to track their quest completion progress with automatic dependency resolution and persistent storage.

**Type**: Client-side web application  
**Technology**: HTML/JavaScript with React and React Flow  
**Storage**: Browser localStorage  
**Deployment**: Static HTML file (no server required)

## Core Functionality

### Quest Visualization

The application displays quests as a directed acyclic graph (DAG) with automatic layout. Each quest is represented as a node, and quest dependencies are shown as directional arrows.

**Visual States**:
1. **Available Quest**: Gold border - quest whose prerequisites are all completed
2. **Completed Quest**: Green background with green border
3. **Locked Quest**: Default dark gray styling - prerequisites not yet met

**Node Types**:
1. **Map Nodes**: Represent map unlock requirements
   - Display map preview image
   - Show map name and lock status
   - Dark gradient background
   - No trader icon
   
2. **Quest Nodes**: Represent actual quests
   - Display trader icon with initial
   - Show quest ID and quest name
   - Display current status (locked/available/completed)
   - Link to wiki page

**Edge Styling**:
- Default edges: Gray with arrows
- Completed paths: Green arrows
- Available paths: Animated lighter gray arrows

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

**Storage**: Browser localStorage key `arcraiders-quest-progress-reactflow`  
**Format**: JSON array of completed quest IDs

**Completion Behavior**:
- Clicking any quest toggles its completion status
- If marking complete and prerequisites are incomplete: prompts to auto-complete all prerequisites
- User can choose to proceed with auto-completion or cancel
- Progress saved automatically to localStorage

**Uncompletion Behavior**:
- Clicking a completed quest to uncomplete it
- If any dependent quests are completed: prompts to also uncomplete all dependents
- User can choose to proceed with cascade or cancel
- Recursive dependency resolution ensures graph consistency

**Confirmation Dialogs**:
- When completing a quest with incomplete prerequisites: Shows list of prerequisites to auto-complete (up to 5, with count if more)
- When uncompleting a quest with completed dependents: Shows list of dependents to uncomplete (up to 5, with count if more)
- User must confirm before cascading changes take effect

### Navigation and Zoom Controls

**Zoom Controls**:
- Zoom in/out buttons in bottom-right
- Mouse wheel to zoom
- Pinch to zoom on trackpad/touch devices
- Fit to viewport button

**Pan Controls**:
- Click and drag to pan the graph
- Mouse wheel / trackpad scroll to pan
- Graph panning is constrained to graph bounds (can't pan into empty space)

**Interaction**:
- Nodes are fixed (not draggable)
- Click on node to toggle completion
- Graph layout is automatic and non-editable

### Quest Interaction

**Click**:
- Toggles quest completion status
- Triggers automatic dependency resolution
- Shows confirmation dialogs when needed
- Updates graph and statistics immediately

**Wiki Link**:
- Each quest node has a "📖 Wiki" button
- Opens quest wiki page in new tab
- Wiki URL format: `https://arcraiders.wiki/wiki/{Quest_Name}`

## User Interface

### Layout Structure

1. **Header**: Fixed at top with application title
2. **Graph Area**: Fills remaining vertical space with interactive quest graph
3. **Statistics**: Fixed at bottom showing completion stats
4. **Zoom Controls**: Overlaid in bottom-right corner of graph

### Display Elements

**Header**:
- Application title: "🎮 ARC Raiders Quest Tracker"
- Fixed position, doesn't scroll with graph

**Zoom Controls**:
- Positioned in bottom-right corner
- Zoom in/out buttons
- Fit to viewport button

**Statistics Display**:
- Positioned at bottom center
- Shows three real-time counters:
  1. **Completed**: Number of quests marked as complete
  2. **Available**: Number of quests currently available to complete  
  3. **Total**: Total quest count (75 including 3 map nodes)

## Technical Implementation

### Dependencies

**External Libraries** (loaded via CDN):
1. React 18.2.0 - UI library
2. React DOM 18.2.0 - DOM rendering
3. React Flow 11.10.4 - Graph visualization
4. Dagre 0.8.5 - Layout algorithm
5. Babel Standalone - JSX transformation

**No Build Process Required**: Single HTML file with inline CSS and JSX.

### Browser Compatibility

**Minimum Requirements**:
- Modern browser with ES6+ support
- localStorage API
- SVG rendering support

**Tested On**:
- Chrome/Edge (Chromium-based)
- Safari (macOS)
- Firefox

## File Structure

```
quest-tracker/
├── index.html                    # Main application (React Flow version)
├── index.html.cytoscape.backup   # Old Cytoscape version backup
├── images/                       # Map preview images
│   ├── Dam_Battlegrounds.png.webp
│   ├── Blue_Gate.png.webp
│   └── Stella_Montis.png.webp
├── README.md                     # User documentation
├── AGENTS.md                     # Maintenance guide
└── SPEC.md                       # This file
```

## Color Scheme

**Background**: Dark theme (#1a1a1a)  
**Text**: Light gray (#e0e0e0)  
**Accents**: Cyan (#4fc3f7)  
**Quest Nodes**: Dark gray (#2c2c2c)  
**Map Nodes**: Dark blue-gray gradient (#263238 to #37474f)  
**Available**: Gold border (#ffd700)  
**Completed**: Green (#1b4d2b background, #2e7d4e border)

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
