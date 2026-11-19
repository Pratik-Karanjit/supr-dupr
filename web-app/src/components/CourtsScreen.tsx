import { MapPin, Phone, MessageCircle, ExternalLink } from 'lucide-react';
import type { Venue } from '../types';

function InstagramIcon({ size = 14 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
      <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
      <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
    </svg>
  );
}

interface Props {
  venues: Venue[];
}

export function CourtsScreen({ venues }: Props) {
  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
        <div>
          <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6 }}>
            <MapPin size={18} color="var(--navy-dark)" /> Verified Pickleball Courts in Nepal
          </div>
          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>
            Real locations, contact numbers, and direct Instagram booking channels
          </div>
        </div>
      </div>

      <div className="courts-grid">
        {venues.map(v => (
          <div
            className="white-card"
            key={v.id}
            style={{
              marginBottom: 0,
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                <div>
                  <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-slate)' }}>{v.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 3, display: 'flex', alignItems: 'center', gap: 4 }}>
                    <MapPin size={12} color="var(--navy-dark)" /> {v.location}
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', gap: 8, margin: '12px 0 8px 0', flexWrap: 'wrap' }}>
                <span style={{ background: '#F1F5F9', fontSize: 11, padding: '4px 9px', borderRadius: 6, fontWeight: 700, color: 'var(--text-slate)' }}>
                  {v.courts} {v.courts === 1 ? 'Court' : 'Courts'}
                </span>
                <span style={{ background: '#F8FAFC', border: '1px solid var(--border-subtle)', fontSize: 11, padding: '4px 9px', borderRadius: 6, fontWeight: 700, color: 'var(--navy-dark)' }}>
                  {v.surface}
                </span>
              </div>

              <div style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 6 }}>
                🕒 {v.hours}
              </div>

              <div style={{ fontSize: 12, color: 'var(--navy-dark)', fontWeight: 700, marginBottom: 14, display: 'flex', alignItems: 'center', gap: 5 }}>
                <InstagramIcon size={13} /> {v.instagramHandle}
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: v.whatsapp ? '1fr 1fr 44px' : '1fr 1fr', gap: 8, marginTop: 'auto' }}>
              {/* Call Inquiry Button (uses real tel: protocol for phone dialer) */}
              <a
                href={`tel:${v.phone}`}
                className="btn-outline-navy"
                style={{ textDecoration: 'none', textAlign: 'center' }}
                title={`Call ${v.phone}`}
              >
                <Phone size={13} /> Call
              </a>

              {/* Instagram Profile & DM Link */}
              <a
                href={v.instagram}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-navy"
                style={{ textDecoration: 'none', padding: '10px 14px' }}
                title={`Visit ${v.instagramHandle} on Instagram`}
              >
                <InstagramIcon size={14} /> Instagram <ExternalLink size={11} style={{ opacity: 0.7 }} />
              </a>

              {/* Optional WhatsApp Quick Chat */}
              {v.whatsapp && (
                <a
                  href={`https://wa.me/${v.whatsapp.replace(/[^0-9]/g, '')}?text=Hi!%20I%20would%20like%20to%20inquire%20about%20pickleball%20court%20booking`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-outline-navy"
                  style={{ textDecoration: 'none', padding: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#16A34A', borderColor: '#BBF7D0' }}
                  title="Chat on WhatsApp"
                >
                  <MessageCircle size={16} />
                </a>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
