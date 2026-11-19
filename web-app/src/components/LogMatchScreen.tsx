import { useState, useMemo } from 'react';
import { Users, User, Shield, UserX, Send, MapPin } from 'lucide-react';
import type { UserProfile, Player, GameScore } from '../types';
import { calculateMatchEngine } from '../services/ratingEngine';

const VERIFIED_VENUES = [
  'The Pickleball Nepal (Boudha)',
  'PickleGo Nepal (Boudha)',
  'Pick & Sip (Kamal Pokhari)',
  'Serve & Sip Pickleball (Kamal Pokhari)',
  'RALLY Pickleball & Courtside Cafe (Bhaktapur)',
  'KickOff Arena (Sitapaila)',
  'Smash Pickleball Nepal (Kathmandu)',
  'Point 11 Pickleball (Kathmandu)',
  'Picklepark Koteshwor',
  'Match and Meals (Sanepa)',
  'BoxArena (Tangal)',
  'The Flash Pickleball Nepal (Sukedhara / Naxal)',
  'Hardik Fitness Club & Pickleball (Pulchowk)',
  'Turf Park (Dholahiti)',
  'Picklepoint Nepal (Sitakwa Marg)',
  'Alley Oops (Sukedhara)',
  'DinkHaus (Meerkat Park, Pokhara)'
];

interface Props {
  user: UserProfile;
  players: Player[];
  onSubmitMatch: (
    isDoubles: boolean,
    partner: string,
    op1: string,
    op2: string,
    venue: string,
    sets: GameScore[]
  ) => void;
}

export function LogMatchScreen({ user, players, onSubmitMatch }: Props) {
  const [isDoubles, setIsDoubles] = useState(true);
  const [partner, setPartner] = useState('Rohan Shrestha');
  const [op1, setOp1] = useState('Bibek Thapa');
  const [op2, setOp2] = useState('Sujan Maharjan');
  const [venue, setVenue] = useState(VERIFIED_VENUES[0]);

  const [scores, setScores] = useState<GameScore[]>([
    { t1: 11, t2: 8 },
    { t1: 9, t2: 11 },
    { t1: 11, t2: 7 }
  ]);

  const updateScore = (gameIdx: number, team: 't1' | 't2', delta: number) => {
    setScores(prev => {
      const next = [...prev];
      const current = next[gameIdx][team];
      const newVal = Math.max(0, current + delta);
      next[gameIdx] = { ...next[gameIdx], [team]: newVal };
      return next;
    });
  };

  const calc = useMemo(() => {
    return calculateMatchEngine(user, players, isDoubles, partner, op1, op2, scores);
  }, [user, players, isDoubles, partner, op1, op2, scores]);

  const handleSubmit = () => {
    onSubmitMatch(isDoubles, partner, op1, op2, venue, scores);
  };

  return (
    <div className="log-grid">
      {/* Left Column: Form & Steppers */}
      <div>
        {/* 2v2 vs 1v1 Toggle */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 14 }}>
          <button
            className={`btn-outline-navy ${isDoubles ? 'active' : ''}`}
            style={isDoubles ? { background: 'var(--navy-dark)', color: '#FFF', borderColor: 'var(--navy-dark)' } : {}}
            onClick={() => setIsDoubles(true)}
          >
            <Users size={14} /> Doubles (2v2)
          </button>
          <button
            className={`btn-outline-navy ${!isDoubles ? 'active' : ''}`}
            style={!isDoubles ? { background: 'var(--navy-dark)', color: '#FFF', borderColor: 'var(--navy-dark)' } : {}}
            onClick={() => setIsDoubles(false)}
          >
            <User size={14} /> Singles (1v1)
          </button>
        </div>

        {/* Roster Selection Card */}
        <div className="white-card">
          <div style={{ fontSize: 11, fontWeight: 800, color: 'var(--text-muted)', marginBottom: 12, letterSpacing: '0.5px' }}>
            ROSTER SELECTION
          </div>

          <div style={{ fontSize: 12, fontWeight: 800, color: 'var(--navy-dark)', marginBottom: 6, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Shield size={13} color="var(--navy-dark)" /> Team 1: {user.name} ({isDoubles ? user.doublesRating.toFixed(3) : user.singlesRating.toFixed(3)})
          </div>

          {isDoubles && (
            <select value={partner} onChange={e => setPartner(e.target.value)}>
              <option value="Rohan Shrestha">Partner: Rohan Shrestha (4.250 • 92% Rel)</option>
              <option value="Bibek Thapa">Partner: Bibek Thapa (3.780 • 80% Rel)</option>
              <option value="Anjali Tamang">Partner: Anjali Tamang (3.910 • 88% Rel)</option>
            </select>
          )}

          <div style={{ fontSize: 12, fontWeight: 800, color: 'var(--coral-loss)', margin: '10px 0 6px 0', display: 'flex', alignItems: 'center', gap: 6 }}>
            <UserX size={13} color="var(--coral-loss)" /> Team 2: Opponent(s)
          </div>

          <select value={op1} onChange={e => setOp1(e.target.value)}>
            <option value="Bibek Thapa">Opponent 1: Bibek Thapa (3.780 • 80% Rel)</option>
            <option value="Anjali Tamang">Opponent 1: Anjali Tamang (3.910 • 88% Rel)</option>
            <option value="Aayush Karki">Opponent 1: Aayush Karki (4.410 • 95% Rel)</option>
          </select>

          {isDoubles && (
            <select value={op2} onChange={e => setOp2(e.target.value)}>
              <option value="Sujan Maharjan">Opponent 2: Sujan Maharjan (2.920 • 60% Rel)</option>
              <option value="Sneha Shakya">Opponent 2: Sneha Shakya (3.420 • 75% Rel)</option>
            </select>
          )}

          <div style={{ fontSize: 12, fontWeight: 800, color: 'var(--text-slate)', margin: '10px 0 6px 0', display: 'flex', alignItems: 'center', gap: 6 }}>
            <MapPin size={13} color="var(--navy-dark)" /> Verified Venue
          </div>
          <select value={venue} onChange={e => setVenue(e.target.value)}>
            {VERIFIED_VENUES.map(v => (
              <option key={v} value={v}>{v}</option>
            ))}
          </select>
        </div>

        {/* Match Scores (Best of 3) */}
        <div className="white-card">
          <div style={{ fontSize: 11, fontWeight: 800, color: 'var(--text-muted)', marginBottom: 12, letterSpacing: '0.5px' }}>
            MATCH SCORES (BEST OF 3)
          </div>

          {scores.map((s, idx) => (
            <div
              key={idx}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: idx < 2 ? 12 : 0
              }}
            >
              <span style={{ fontWeight: 800, fontSize: 13, color: 'var(--text-slate)' }}>Game {idx + 1}</span>
              <div style={{ display: 'flex', alignItems: 'center' }}>
                <div className="stepper-control">
                  <button onClick={() => updateScore(idx, 't1', -1)}>-</button>
                  <span style={{ color: 'var(--emerald-win)' }}>{s.t1}</span>
                  <button onClick={() => updateScore(idx, 't1', 1)}>+</button>
                </div>
                <span style={{ margin: '0 8px', fontWeight: 800, color: 'var(--text-muted)' }}>:</span>
                <div className="stepper-control">
                  <button onClick={() => updateScore(idx, 't2', -1)}>-</button>
                  <span style={{ color: 'var(--coral-loss)' }}>{s.t2}</span>
                  <button onClick={() => updateScore(idx, 't2', 1)}>+</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Right Column (Desktop): Sticky Forecast & Submit */}
      <div className="log-sticky-col">
        {/* 5-Point Custom Algorithm Live Breakdown Card */}
        <div className="white-card" style={{ padding: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <div>
              <div style={{ fontSize: 14, fontWeight: 800, color: 'var(--text-slate)' }}>Rating Delta Forecast</div>
              <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>5-Point Dynamic Elo Engine</div>
            </div>
            <span
              className="mono"
              style={{
                fontSize: 20,
                fontWeight: 900,
                color: calc.delta >= 0 ? 'var(--emerald-win)' : 'var(--coral-loss)'
              }}
            >
              {calc.delta > 0 ? '+' + calc.delta.toFixed(3) : calc.delta.toFixed(3)} SUPR
            </span>
          </div>

          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: 8,
              paddingTop: 12,
              borderTop: '1px solid var(--border-light)',
              textAlign: 'center',
              fontSize: 10
            }}
          >
            <div style={{ background: '#F8FAFC', padding: '9px 6px', borderRadius: 8, border: '1px solid var(--border-light)' }}>
              <div style={{ color: 'var(--text-muted)', fontWeight: 600 }}>Win Chance</div>
              <div className="mono" style={{ fontWeight: 800, color: 'var(--navy-dark)', fontSize: 14, marginTop: 2 }}>
                {calc.expectedT1Prob}%
              </div>
            </div>
            <div style={{ background: '#F8FAFC', padding: '9px 6px', borderRadius: 8, border: '1px solid var(--border-light)' }}>
              <div style={{ color: 'var(--text-muted)', fontWeight: 600 }}>PD Factor</div>
              <div className="mono" style={{ fontWeight: 800, color: 'var(--navy-dark)', fontSize: 14, marginTop: 2 }}>
                {calc.pdFactor}x
              </div>
            </div>
            <div style={{ background: '#F8FAFC', padding: '9px 6px', borderRadius: 8, border: '1px solid var(--border-light)' }}>
              <div style={{ color: 'var(--text-muted)', fontWeight: 600 }}>Dynamic K</div>
              <div className="mono" style={{ fontWeight: 800, color: 'var(--navy-dark)', fontSize: 14, marginTop: 2 }}>
                {calc.dynamicK}
              </div>
            </div>
          </div>

          <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 12, lineHeight: 1.4, background: '#F8FAFC', padding: '8px 10px', borderRadius: 8 }}>
            Opponent average: <strong>{calc.t2Avg.toFixed(3)}</strong> • Team average: <strong>{calc.t1Avg.toFixed(3)}</strong>
          </div>
        </div>

        <button className="btn-navy" style={{ padding: 14 }} onClick={handleSubmit}>
          <Send size={16} /> Submit & Generate Verification Code
        </button>
      </div>
    </div>
  );
}
