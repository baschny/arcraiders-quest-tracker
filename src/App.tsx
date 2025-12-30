import { useState, useEffect } from 'react';
import { QuestTracker } from './components/QuestTracker';
import { Quest } from './types/quest';
import { MAP_NODES } from './data/static-data';

export function App() {
  const [questData, setQuestData] = useState<Quest[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('/quest-data.json')
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to load quest data');
        }
        return response.json();
      })
      .then((data: Quest[]) => {
        // Combine MAP_NODES with loaded quest data
        const allQuests = [...MAP_NODES, ...data];
        setQuestData(allQuests);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          background: '#1a1a1a',
          color: '#e0e0e0',
          fontSize: '18px',
        }}
      >
        Loading quest data...
      </div>
    );
  }

  if (error) {
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          background: '#1a1a1a',
          color: '#e53935',
          fontSize: '18px',
        }}
      >
        Error: {error}
      </div>
    );
  }

  if (!questData) {
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          background: '#1a1a1a',
          color: '#e0e0e0',
          fontSize: '18px',
        }}
      >
        No quest data available
      </div>
    );
  }

  return <QuestTracker quests={questData} />;
}
