import { useState } from 'react';
import { Clock, CheckCircle2, MapPin, Check, X } from 'lucide-react';
import type { Match } from '../types';

interface Props {
  matches: Match[];
  onConfirm: (id: string) => void;
  onDispute: (id: string) => void;
}

export function VerificationQueueScreen({ matches, onConfirm, onDispute }: Props) {
  const [filterCode, setFilterCode] = useState('');

  const filtered = matches.filter(m => {
    if (!filterCode.trim()) return true;
    return m.code.toLowerCase().includes(filterCode.toLowerCase().trim());
  });

  const pending = filtered.filter(m => m.status === 'pending');
  const confirmed = filtered.filter(m => m.status === 'confirmed');

  return (
    <div>
      <div style={{ position: 'relative', marginBottom: 16 }}>
        <input
          type="text"
          className="input-field-clean"
          placeholder="Lookup Match Code (e.g. NPR-834)..."
          value={filterCode}
          onChange={e => setFilterCode(e.target.value)}
          style={{ marginBottom: 0, padding: '14px 16px', fontSize: 14 }}
        />
      </div>

      <div className="verify-grid">
        {/* Left Column: Awaiting Review */}
        <div>
          <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 12, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6 }}>
            <Clock size={16} color="var(--warning-amber)" /> Awaiting Opponent Review ({pending.length})
          </div>

          {pending.length === 0 && (
            <div className="white-card" style={{ textAlign: 'center', color: 'var(--text-muted)', fontSize: 13, padding: 32 }}>
              No pending matches waiting for review.
            </div>
          )}

          {pending.map(m => (
            <div className="scorecard" key={m.id} style={{ borderLeft: '3px solid var(--warning-amber)' }}>
              <div className="scorecard-meta-bar">
                <span className="meta-venue">
                  <MapPin size={11} color="var(--navy-dark)" /> {m.venue.split('(')[0]}
                </span>
                <span className="meta-code">#{m.code}</span>
              </div>

              <div style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-slate)', marginBottom: 6 }}>
                {m.team1} vs {m.team2}
              </div>

              <div className="mono" style={{ fontSize: 15, fontWeight: 800, color: 'var(--navy-dark)', marginBottom: 8 }}>
                {m.sets.map(s => `${s.t1}-${s.t2}`).join(', ')}
              </div>

              <div style={{ fontSize: 11, color: 'var(--text-muted)', marginBottom: 14 }}>
                Logged by {m.loggedBy}
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <button
                  className="btn-outline-navy"
                  style={{ color: 'var(--coral-loss)', borderColor: '#FECACA' }}
                  onClick={() => onDispute(m.id)}
                >
                  <X size={14} /> Dispute
                </button>
                <button
                  className="btn-navy"
                  style={{ padding: '10px 16px' }}
                  onClick={() => onConfirm(m.id)}
                >
                  <Check size={14} /> Confirm Score
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Right Column: Officially Confirmed */}
        <div>
          <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 12, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6 }}>
            <CheckCircle2 size={16} color="var(--emerald-win)" /> Officially Confirmed ({confirmed.length})
          </div>

          {confirmed.length === 0 && (
            <div className="white-card" style={{ textAlign: 'center', color: 'var(--text-muted)', fontSize: 13, padding: 32 }}>
              No confirmed matches yet.
            </div>
          )}

          {confirmed.map(m => (
            <div className="scorecard" key={m.id} style={{ padding: '14px 16px', marginBottom: 10 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontWeight: 800, fontSize: 14, color: 'var(--text-slate)' }}>
                  {m.team1} vs {m.team2}
                </span>
                <span className="rating-delta-chip delta-win-chip">
                  +{m.delta.toFixed(3)} SUPR
                </span>
              </div>
              <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 4 }}>
                {m.venue.split('(')[0]} • {m.sets.map(s => `${s.t1}-${s.t2}`).join(', ')}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
