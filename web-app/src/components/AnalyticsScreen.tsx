import { MapPin, Shield, Users, User, TrendingUp, TrendingDown, Clock } from 'lucide-react';
import type { UserProfile, Match } from '../types';

interface Props {
  user: UserProfile;
  matches: Match[];
  isDoubles: boolean;
  setIsDoubles: (v: boolean) => void;
}

export function AnalyticsScreen({ user, matches, isDoubles, setIsDoubles }: Props) {
  const rating = isDoubles ? user.doublesRating : user.singlesRating;

  const points = user.history.map((h, i) => {
    const x = 25 + (i * (290 / Math.max(user.history.length - 1, 1)));
    const y = 95 - ((h.rating - 3.0) * 115);
    return `${x},${y}`;
  }).join(' ');

  return (
    <div className="analytics-grid">
      {/* Left Column (Desktop) / Top Section (Mobile) */}
      <div>
        {/* Hero Rating Card */}
        <div className="hero-rating-card">
          <div className="profile-hero-row">
            <div className="avatar-circle">PS</div>
            <div>
              <div className="hero-name">{user.name}</div>
              <div className="hero-meta">
                <MapPin size={12} color="#38BDF8" /> {user.city}, Nepal
                <span>•</span>
                {user.homeHub.split('(')[0]}
              </div>
            </div>
          </div>

          <div className="hero-rating-grid">
            <div className={`rating-tab-box ${isDoubles ? 'active' : ''}`} onClick={() => setIsDoubles(true)}>
              <div className="rating-tab-label"><span>DOUBLES SUPR</span><Users size={11} /></div>
              <div className="rating-tab-num">{user.doublesRating.toFixed(3)}</div>
            </div>
            <div className={`rating-tab-box ${!isDoubles ? 'active' : ''}`} onClick={() => setIsDoubles(false)}>
              <div className="rating-tab-label"><span>SINGLES SUPR</span><User size={11} /></div>
              <div className="rating-tab-num">{user.singlesRating.toFixed(3)}</div>
            </div>
          </div>

          <div className="hero-reliability">
            <div className="rel-header">
              <span style={{ color: '#94A3B8' }}><Shield size={12} color="#38BDF8" style={{ verticalAlign: '-2px' }} /> Reliability Score</span>
              <span style={{ color: '#FFF', fontWeight: 800 }}>{user.reliability}% <span style={{ color: '#059669', fontSize: 10 }}>(OFFICIAL)</span></span>
            </div>
            <div className="rel-track"><div className="rel-fill" style={{ width: `${user.reliability}%` }} /></div>
          </div>
        </div>

        {/* Stats Row */}
        <div className="stats-grid-row">
          <div className="stat-card-white">
            <div className="stat-val-bold">{user.matchesPlayed}</div>
            <div className="stat-label-muted">Matches</div>
          </div>
          <div className="stat-card-white">
            <div className="stat-val-bold">
              <span style={{ color: 'var(--emerald-win)' }}>{user.wins}W</span>
              <span style={{ color: '#CBD5E1', fontWeight: 400 }}> - </span>
              <span style={{ color: 'var(--coral-loss)' }}>{user.losses}L</span>
            </div>
            <div className="stat-label-muted">Record</div>
          </div>
          <div className="stat-card-white">
            <div className="stat-val-bold">{Math.round((user.wins / user.matchesPlayed) * 100)}%</div>
            <div className="stat-label-muted">Win Rate</div>
          </div>
        </div>
      </div>

      {/* Right Column (Desktop) / Bottom Section (Mobile) */}
      <div>
        {/* Trajectory Chart */}
        <div className="white-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div>
              <div style={{ fontSize: 14, fontWeight: 800, color: 'var(--text-slate)' }}>{isDoubles ? 'Doubles' : 'Singles'} Performance Trajectory</div>
              <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>Verified match rating changes</div>
            </div>
            <span className="mono" style={{ fontSize: 13, fontWeight: 800, color: 'var(--navy-dark)', background: '#F1F5F9', padding: '3px 8px', borderRadius: 6 }}>
              {rating.toFixed(3)}
            </span>
          </div>
          <svg width="100%" height="115" viewBox="0 0 340 115" preserveAspectRatio="none">
            <line x1="0" y1="25" x2="340" y2="25" stroke="#E2E8F0" strokeWidth="1" strokeDasharray="2 2" />
            <line x1="0" y1="65" x2="340" y2="65" stroke="#E2E8F0" strokeWidth="1" strokeDasharray="2 2" />
            <polyline fill="none" stroke="#0EA5E9" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" points={points} />
            {user.history.map((h, i) => {
              const x = 25 + (i * (290 / Math.max(user.history.length - 1, 1)));
              const y = 95 - ((h.rating - 3.0) * 115);
              return <circle key={i} cx={x} cy={y} r={4} fill="#FFF" stroke="#0EA5E9" strokeWidth={2} />;
            })}
          </svg>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: 'var(--text-muted)', fontWeight: 600, marginTop: 6 }}>
            <span>{user.history[0]?.date}</span>
            <span>Historical Progression</span>
            <span>{user.history[user.history.length - 1]?.date}</span>
          </div>
        </div>

        {/* Recent Matches */}
        <div className="match-feed-header">
          <span className="section-title">Recent Matches</span>
          <span className="feed-count">{matches.length} Total</span>
        </div>

        {matches.map(m => {
          const isPending = m.status === 'pending';
          const isTeam1Winner = m.winnerTeam === 1;
          const userInTeam1 = m.team1.includes('Pratik Sharma');
          const isUserWinner = userInTeam1 ? isTeam1Winner : !isTeam1Winner;

          return (
            <div className="scorecard" key={m.id}>
              <div className="scorecard-meta-bar">
                <span className="meta-venue"><MapPin size={10} color="var(--navy-dark)" /> {m.venue.split('(')[0]}</span>
                <span className="meta-code">{m.date} • #{m.code}</span>
              </div>

              <div className={`team-row ${isTeam1Winner ? 'winner' : ''}`}>
                <div className="team-name-col"><div className="win-indicator-dot" /><span>{m.team1}</span></div>
                <div className="set-scores-wrap">
                  {m.sets.map((s, i) => <div key={i} className={`set-cell ${s.t1 > s.t2 ? 'winning-set' : ''}`}>{s.t1}</div>)}
                </div>
              </div>

              <div className={`team-row ${!isTeam1Winner ? 'winner' : ''}`}>
                <div className="team-name-col"><div className="win-indicator-dot" /><span>{m.team2}</span></div>
                <div className="set-scores-wrap">
                  {m.sets.map((s, i) => <div key={i} className={`set-cell ${s.t2 > s.t1 ? 'winning-set' : ''}`}>{s.t2}</div>)}
                </div>
              </div>

              <div className="scorecard-footer">
                <div className={`rating-delta-chip ${isPending ? 'delta-pending-chip' : (isUserWinner ? 'delta-win-chip' : 'delta-loss-chip')}`}>
                  {isPending ? <Clock size={12} /> : (isUserWinner ? <TrendingUp size={12} /> : <TrendingDown size={12} />)}
                  <span>{isPending ? 'Pending' : (isUserWinner ? '+' + m.delta.toFixed(3) : m.delta.toFixed(3))} SUPR</span>
                </div>
                <span className="status-note">{isPending ? 'Awaiting verification' : 'Official match'}</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
