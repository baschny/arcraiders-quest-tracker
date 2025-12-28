# ARC Raiders Quest Tracker

An interactive web application to track your quest progress in ARC Raiders.

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

## Usage

### Opening the Tracker

Simply open `index.html` in your web browser. No server or installation required!

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

- **Single-file application**: No external dependencies
- **localStorage**: Progress is saved in your browser
- **Responsive design**: Works on desktop and mobile browsers
- **No network required**: Works completely offline

## Updating Quest Data

For maintainers: To regenerate quest data from the source JSON files:

```bash
cd quest-tracker
./generate-quest-data.sh
```

This extracts quest data from `../quests/*.json` and generates `quests-data.json` with blueprint detection. See `AGENTS.md` for complete update instructions.

## Notes

- Progress is stored per browser, so using a different browser or clearing browser data will reset your progress
- The application automatically handles quest chains - completing prerequisites unlocks subsequent quests
