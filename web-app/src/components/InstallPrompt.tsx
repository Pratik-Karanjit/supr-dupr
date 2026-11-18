import { useState, useEffect } from 'react';
import { Download, X, Smartphone, Monitor, Share, CheckCircle2 } from 'lucide-react';

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

export function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [isInstalled, setIsInstalled] = useState(false);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    // Check if already running as installed standalone PWA
    if (window.matchMedia('(display-mode: standalone)').matches || (window.navigator as unknown as { standalone?: boolean }).standalone) {
      setIsInstalled(true);
    }

    const handler = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e as BeforeInstallPromptEvent);
    };

    window.addEventListener('beforeinstallprompt', handler);
    window.addEventListener('appinstalled', () => {
      setIsInstalled(true);
      setShowModal(false);
    });

    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  const handleInstallClick = async () => {
    if (deferredPrompt) {
      await deferredPrompt.prompt();
      const choice = await deferredPrompt.userChoice;
      if (choice.outcome === 'accepted') {
        setIsInstalled(true);
      }
      setDeferredPrompt(null);
    } else {
      setShowModal(true);
    }
  };

  return (
    <>
      {/* PWA Status / Install Bar */}
      <div
        style={{
          background: 'var(--navy-surface)',
          border: '1px solid var(--navy-border)',
          borderRadius: 12,
          padding: '10px 14px',
          marginBottom: 14,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          color: '#FFFFFF'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div
            style={{
              width: 26,
              height: 26,
              borderRadius: 6,
              background: isInstalled ? 'var(--emerald-bg)' : '#1E3A5F',
              border: '1px solid var(--navy-border)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: isInstalled ? 'var(--emerald-win)' : '#38BDF8'
            }}
          >
            {isInstalled ? <CheckCircle2 size={15} /> : <Download size={15} />}
          </div>
          <div>
            <div style={{ fontSize: 12, fontWeight: 800 }}>
              {isInstalled ? 'Running as PWA App' : 'Progressive Web App (PWA)'}
            </div>
            <div style={{ fontSize: 10, color: '#94A3B8' }}>
              {isInstalled ? 'Installed on device • Offline enabled' : 'Install to Home Screen & App Drawer'}
            </div>
          </div>
        </div>

        {!isInstalled && (
          <button
            onClick={handleInstallClick}
            style={{
              background: '#38BDF8',
              color: 'var(--navy-dark)',
              border: 'none',
              borderRadius: 8,
              padding: '6px 12px',
              fontSize: 11,
              fontWeight: 800,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 4
            }}
          >
            <Download size={12} />
            Install
          </button>
        )}
      </div>

      {/* Instructions Modal if browser doesn't trigger prompt directly */}
      {showModal && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(10, 20, 40, 0.65)',
            backdropFilter: 'blur(4px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 16,
            zIndex: 999
          }}
          onClick={() => setShowModal(false)}
        >
          <div
            style={{
              background: '#FFFFFF',
              borderRadius: 20,
              padding: 20,
              maxWidth: 400,
              width: '100%',
              boxShadow: '0 20px 40px rgba(10, 20, 40, 0.3)',
              border: '1px solid var(--border-subtle)'
            }}
            onClick={e => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
              <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 8 }}>
                <Smartphone size={18} color="var(--navy-dark)" /> How to Install PWA
              </div>
              <button
                onClick={() => setShowModal(false)}
                style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', padding: 4 }}
              >
                <X size={18} />
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {/* Desktop Chrome / Edge */}
              <div style={{ background: '#F8FAFC', padding: 12, borderRadius: 12, border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 800, fontSize: 13, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                  <Monitor size={15} color="var(--navy-dark)" /> On Chrome / Edge (Desktop)
                </div>
                <div style={{ fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.4 }}>
                  Look at the right side of the address bar above: click the <strong>Install icon</strong> (computer screen with down arrow) or click <strong>Menu (⋮) → "Install SUPR DUPR..."</strong>.
                </div>
              </div>

              {/* iOS Safari */}
              <div style={{ background: '#F8FAFC', padding: 12, borderRadius: 12, border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 800, fontSize: 13, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                  <Share size={15} color="var(--navy-dark)" /> On iPhone / iPad (Safari)
                </div>
                <div style={{ fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.4 }}>
                  Tap the <strong>Share</strong> button at the bottom of Safari, scroll down, and tap <strong>"Add to Home Screen"</strong>.
                </div>
              </div>

              {/* Android */}
              <div style={{ background: '#F8FAFC', padding: 12, borderRadius: 12, border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 800, fontSize: 13, color: 'var(--text-slate)', display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                  <Smartphone size={15} color="var(--navy-dark)" /> On Android (Chrome)
                </div>
                <div style={{ fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.4 }}>
                  Tap the three dots <strong>(⋮)</strong> in the top right corner and tap <strong>"Install app"</strong> or <strong>"Add to Home screen"</strong>.
                </div>
              </div>
            </div>

            <button
              className="btn-navy"
              style={{ marginTop: 16 }}
              onClick={() => setShowModal(false)}
            >
              Got it
            </button>
          </div>
        </div>
      )}
    </>
  );
}
