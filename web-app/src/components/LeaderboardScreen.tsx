import { useState } from 'react';
import type { Player, UserProfile } from '../types';

interface Props {
  user: UserProfile;
  players: Player[];
  isDoubles: boolean;
}

export function LeaderboardScreen({ user, players, isDoubles }: Props) {
  const [filter, setFilter] = useState('All Nepal');
  const categories = [
    'All Nepal',
    'Kathmandu',
    'Pokhara',
    'The Pickleball Nepal',
    'Flash Pickleball',
    'Picklepoint Nepal',
    'BoxArena',
    'Pick & Sip',
    'DinkHaus'
  ];

  const allList: (Player | (UserProfile & { hub: string; singles: number; doubles: number; rel: number; matches: number }))[] = [
    ...players,
    {
      ...user,
      hub: user.homeHub,
      singles: user.singlesRating,
      doubles: user.doublesRating,
      rel: user.reliability,
      matches: user.matchesPlayed
    }
  ];

  const filtered = allList.filter(p => {
    if (filter === 'All Nepal') return true;
    if (filter === 'Kathmandu') return p.city === 'Kathmandu' || p.city === 'Lalitpur';
    if (filter === 'Pokhara') return p.city === 'Pokhara';
    return p.hub.includes(filter.split(' ')[0]);
  }).sort((a, b) => {
    const rA = isDoubles ? a.doubles : a.singles;
    const rB = isDoubles ? b.doubles : b.singles;
    return rB - rA;
  });

  return (
    <div>
      {/* Category Scroll Filter */}
      <div className="chip-scroll">
        {categories.map(c => (
          <div
            key={c}
            className={`chip-white ${filter === c ? 'active' : ''}`}
            onClick={() => setFilter(c)}
          >
            {c}
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: 'var(--text-muted)', fontWeight: 700, padding: '0 8px 10px 8px', letterSpacing: '0.5px' }}>
        <span>PLAYER</span>
        <span>{isDoubles ? 'DOUBLES' : 'SINGLES'} SUPR</span>
      </div>

      <div className="leaderboard-table">
        {filtered.map((p, idx) => {
          const rank = idx + 1;
          const isUser = p.id === user.id;
          const rating = isDoubles ? p.doubles : p.singles;
          const rankStr = rank < 10 ? '0' + rank : rank;

          return (
            <div className={`rank-row ${isUser ? 'current-user' : ''}`} key={p.id}>
              <div className="rank-left-section">
                <div className="rank-pos">{rankStr}</div>
                <div className="player-details">
                  <div className="player-name-text">
                    {p.name}
                    {isUser && <span className="you-pill">YOU</span>}
                  </div>
                  <div className="player-subline">
                    {p.city} • {p.hub.split('(')[0]}
                  </div>
                </div>
              </div>

              <div className="rank-right-section">
                <div className="rating-display-val">{rating.toFixed(3)}</div>
                <div className={`reliability-stat ${p.rel >= 60 ? 'official' : ''}`}>
                  {p.rel}% Rel • {p.wins}W-{p.losses}L
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
