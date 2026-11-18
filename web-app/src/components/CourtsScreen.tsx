import { MapPin, Phone, CheckCircle, Crosshair } from 'lucide-react';
import type { Venue } from '../types';

interface Props {
  venues: Venue[];
  checkedInVenueId: string | null;
  onToggleCheckIn: (id: string, name: string) => void;
  showToast: (msg: string) => void;
}

export function CourtsScreen({ venues, checkedInVenueId, onToggleCheckIn, showToast }: Props) {
  return (
    <div>
      <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 16, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6 }}>
        <MapPin size={16} color="var(--navy-dark)" /> Courts & Pickleball Clubs in Nepal
      </div>

      <div className="courts-grid">
        {venues.map(v => {
          const isHere = checkedInVenueId === v.id;
          return (
            <div
              className="white-card"
              key={v.id}
              style={{
                marginBottom: 0,
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                ...(isHere ? { borderColor: 'var(--navy-dark)', borderWidth: 1.5 } : {})
              }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                  <div>
                    <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-slate)' }}>{v.name}</div>
                    <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2, display: 'flex', alignItems: 'center', gap: 4 }}>
                      <MapPin size={12} color="var(--navy-dark)" /> {v.location}
                    </div>
                  </div>
                  {isHere && (
                    <span style={{ background: 'var(--navy-dark)', color: '#FFF', fontSize: 9, fontWeight: 900, padding: '3px 8px', borderRadius: 4 }}>
                      CHECKED IN
                    </span>
                  )}
                </div>

                <div style={{ display: 'flex', gap: 8, margin: '12px 0' }}>
                  <span style={{ background: '#F1F5F9', fontSize: 11, padding: '4px 9px', borderRadius: 6, fontWeight: 700, color: 'var(--text-slate)' }}>
                    {v.courts} Courts
                  </span>
                  <span style={{ background: 'var(--emerald-bg)', fontSize: 11, padding: '4px 9px', borderRadius: 6, color: 'var(--emerald-win)', fontWeight: 700 }}>
                    ● {v.active + (isHere ? 1 : 0)} Active Players
                  </span>
                </div>

                <div style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 16 }}>
                  {v.hours} • {v.surface}
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginTop: 'auto' }}>
                <button
                  className="btn-outline-navy"
                  onClick={() => showToast(`Calling ${v.phone}...`)}
                >
                  <Phone size={13} /> Inquire / Book
                </button>
                <button
                  className="btn-navy"
                  style={{ padding: 10 }}
                  onClick={() => onToggleCheckIn(v.id, v.name)}
                >
                  {isHere ? <CheckCircle size={14} /> : <Crosshair size={14} />}
                  {isHere ? 'Check Out' : 'Check In'}
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
