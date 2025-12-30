# ARC Raiders Quest Tracker

An interactive web application to track your quest progress in ARC Raiders.
Based on data from https://github.com/RaidTheory/arcraiders-data (https://arctracker.io/).

## Features

- **Visual Quest Tree**: Quests are organized vertically by their progression tiers
- **Progress Tracking**: Click on quests to mark them as completed
- **Auto-Save**: Your progress is automatically saved in your browser
- **Smart Dependencies**: 
  - Available quests (those you can currently do) are highlighted in gold
  - Completed quests appear faded
  - When unmarking a quest, dependent quests are also unmarked (with confirmation if multiple)
- **Trader Color Coding**: Each trader has a distinct color for easy identification
- **Statistics**: Track completed, available, and total quests
- **Search**: Search for quests in the sidebar to quickly jump to them

## Development

### Installation

```bash
npm install
```

### Generate Quest Data

Before running the application, generate the quest data:

```bash
npm run generate-data
```

This extracts quest data from `../arcraiders-data/quests/*.json` and creates `public/quest-data.json`.

### Development Server

Run the development server with hot module replacement:

```bash
npm run dev
```

Open http://localhost:5173 in your browser.

### Production Build

Build the application for production:

```bash
npm run build
```

The build output will be in the `dist/` directory, ready to deploy to any static web server.

### Preview Production Build

Preview the production build locally:

```bash
npm run preview
```

## Usage

### Tracking Quests

1. **Mark Complete**: Click on any available (gold-bordered) quest to mark it as completed
2. **Unmark**: Click on a completed (faded) quest to unmark it
3. **Auto-Save**: Your progress is automatically saved as you go

### Managing Progress

- **Reset All**: Click "Reset All Progress" to start over

### Visual Guide

- **Gold Border + Glow**: Quest is available to complete
- **Faded/Dark**: Quest is completed
- **Normal**: Quest is locked (prerequisites not met)

### Trader Colors

- **Purple**: Celeste
- **Orange**: Shani
- **Green**: Lance
- **Red**: Tian Wen
- **Blue**: Apollo

## Data

The quest data is embedded directly in the HTML file and includes:
- 72 quests from ARC Raiders Tech Test 2
- Quest names (English)
- Quest IDs
- Trader assignments
- Quest dependencies (previous and next quests)

## Technical Details

- **Stack**: Vite + React + TypeScript + SCSS
- **Graph Layout**: Dagre for automatic hierarchical layout
- **Visualization**: ReactFlow for interactive node-based UI
- **localStorage**: Progress is saved in your browser
- **Responsive design**: Works on desktop and mobile browsers
- **Static deployment**: No backend required, can be hosted on any static web server

## Notes

- Progress is stored per browser, so using a different browser or clearing browser data will reset your progress
- The application automatically handles quest chains - completing prerequisites unlocks subsequent quests
