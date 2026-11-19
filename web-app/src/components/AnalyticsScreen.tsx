import { MapPin, Shield, Users, User, TrendingUp, TrendingDown, Clock } from 'lucide-react';
import type { UserProfile, Match } from '../types';

interface Props {
  user: UserProfile;
  matches: Match[];
  isDoubles: boolean;
  setIsDoubles: (v: boolean) => void;
}

export function AnalyticsScreen({ user, matches, isDoubles, setIsDoubles }: Props) {
  const currentRating = isDoubles ? user.doublesRating : user.singlesRating;

  // Professional Scaled Trajectory Chart Math
  const W = 700;
  const H = 220;
  const leftPad = 52;
  const rightPad = 32;
  const topPad = 32;
  const bottomPad = 36;
  const plotWidth = W - leftPad - rightPad;
  const plotHeight = H - topPad - bottomPad;

  const minRating = 3.000;
  const maxRating = 3.700;
  const ratingRange = maxRating - minRating;

  const getY = (val: number) => {
    const clamped = Math.max(minRating, Math.min(maxRating, val));
    return topPad + plotHeight - ((clamped - minRating) / ratingRange) * plotHeight;
  };

  const getX = (idx: number, total: number) => {
    if (total <= 1) return leftPad + plotWidth / 2;
    return leftPad + (idx / (total - 1)) * plotWidth;
  };

  const points = user.history.map((h, i) => `${getX(i, user.history.length)},${getY(h.rating)}`).join(' ');

  // Y-axis grid lines at 3.60, 3.40, 3.20, 3.00
  const yTicks = [3.600, 3.400, 3.200, 3.000];

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
        {/* Generous Sports Trajectory Chart */}
        <div className="white-card" style={{ padding: '20px 22px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <div>
              <div style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-slate)' }}>
                {isDoubles ? 'Doubles' : 'Singles'} Rating Progression Curve
              </div>
              <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                Official verified performance trajectory across recent match events
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: 10, fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase' }}>CURRENT</div>
              <span className="mono" style={{ fontSize: 15, fontWeight: 900, color: 'var(--navy-dark)', background: '#F1F5F9', padding: '4px 10px', borderRadius: 8 }}>
                {currentRating.toFixed(3)}
              </span>
            </div>
          </div>

          <div style={{ width: '100%', height: 'auto', overflow: 'hidden' }}>
            <svg
              viewBox={`0 0 ${W} ${H}`}
              style={{ width: '100%', height: 'auto', display: 'block' }}
            >
              {/* Horizontal Grid lines and Y-axis labels */}
              {yTicks.map(t => {
                const y = getY(t);
                return (
                  <g key={t}>
                    <text
                      x={leftPad - 10}
                      y={y + 4}
                      textAnchor="end"
                      fill="#94A3B8"
                      fontSize="10"
                      fontFamily="'JetBrains Mono', monospace"
                      fontWeight="600"
                    >
                      {t.toFixed(2)}
                    </text>
                    <line
                      x1={leftPad}
                      y1={y}
                      x2={W - rightPad}
                      y2={y}
                      stroke="#E2E8F0"
                      strokeWidth="1"
                      strokeDasharray="4 4"
                    />
                  </g>
                );
              })}

              {/* Area fill under curve */}
              <polygon
                points={`${points} ${getX(user.history.length - 1, user.history.length)},${topPad + plotHeight} ${leftPad},${topPad + plotHeight}`}
                fill="#0EA5E9"
                fillOpacity="0.08"
              />

              {/* Main trajectory path */}
              <polyline
                fill="none"
                stroke="#0EA5E9"
                strokeWidth="3.5"
                strokeLinecap="round"
                strokeLinejoin="round"
                points={points}
              />

              {/* Nodes and Tooltip Pills */}
              {user.history.map((h, i) => {
                const cx = getX(i, user.history.length);
                const cy = getY(h.rating);
                return (
                  <g key={i}>
                    {/* Node Circle */}
                    <circle cx={cx} cy={cy} r={6} fill="#FFFFFF" stroke="#0EA5E9" strokeWidth={3} />

                    {/* Value Badge above node */}
                    <rect
                      x={cx - 24}
                      y={cy - 24}
                      width={48}
                      height={18}
                      rx={5}
                      fill="#1E3A5F"
                    />
                    <text
                      x={cx}
                      y={cy - 12}
                      textAnchor="middle"
                      fill="#FFFFFF"
                      fontSize="10"
                      fontFamily="'JetBrains Mono', monospace"
                      fontWeight="800"
                    >
                      {h.rating.toFixed(2)}
                    </text>

                    {/* Date label under node */}
                    <text
                      x={cx}
                      y={topPad + plotHeight + 20}
                      textAnchor="middle"
                      fill="#64748B"
                      fontSize="11"
                      fontWeight="700"
                    >
                      {h.date}
                    </text>
                  </g>
                );
              })}
            </svg>
          </div>
        </div>

        {/* Recent Matches Scorecards */}
        <div className="match-feed-header" style={{ marginTop: 20 }}>
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
                <span className="meta-venue"><MapPin size={11} color="var(--navy-dark)" /> {m.venue.split('(')[0]}</span>
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
