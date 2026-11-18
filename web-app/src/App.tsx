import { BarChart3, PlusCircle, ShieldCheck, Trophy, MapPin, Settings2, Shield, User } from 'lucide-react';
import { useAppState } from './hooks/useAppState';
import { AnalyticsScreen } from './components/AnalyticsScreen';
import { LogMatchScreen } from './components/LogMatchScreen';
import { VerificationQueueScreen } from './components/VerificationQueueScreen';
import { LeaderboardScreen } from './components/LeaderboardScreen';
import { CourtsScreen } from './components/CourtsScreen';
import { InstallPrompt } from './components/InstallPrompt';
import type { TabId } from './types';

export function App() {
  const {
    state,
    activeTab,
    setActiveTab,
    isDoubles,
    setIsDoubles,
    checkedInVenueId,
    toast,
    showToast,
    submitMatch,
    confirmMatch,
    disputeMatch,
    toggleCheckIn
  } = useAppState();

  const pendingCount = state.matches.filter(m => m.status === 'pending').length;

  const titles: Record<TabId, string> = {
    profile: 'Player Analytics',
    log: 'Log Match',
    verify: 'Verification Queue',
    leaderboard: 'SUPR Rankings',
    courts: 'Courts & Hubs'
  };

  const navItems: { id: TabId; label: string; icon: typeof BarChart3; badge?: number }[] = [
    { id: 'profile', label: 'Analytics', icon: BarChart3 },
    { id: 'log', label: 'Log Match', icon: PlusCircle },
    { id: 'verify', label: 'Verify', icon: ShieldCheck, badge: pendingCount },
    { id: 'leaderboard', label: 'Rankings', icon: Trophy },
    { id: 'courts', label: 'Courts & Hubs', icon: MapPin }
  ];

  return (
    <div className="app-shell">
      {/* Toast Notification */}
      {toast && (
        <div className="toast-pill">
          ✓ {toast}
        </div>
      )}

      {/* Desktop Sidebar (visible on screens >= 1024px) */}
      <aside className="desktop-sidebar">
        <div className="sidebar-brand-row">
          <div className="sidebar-logo">SD</div>
          <div>
            <div style={{ fontSize: 16, fontWeight: 900, letterSpacing: '-0.3px', color: '#FFFFFF' }}>
              SUPR DUPR
            </div>
            <div style={{ fontSize: 11, color: '#38BDF8', fontWeight: 700, letterSpacing: '0.5px' }}>
              NEPAL PICKLEBALL
            </div>
          </div>
        </div>

        <nav className="sidebar-nav-list">
          {navItems.map(item => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                className={`sidebar-nav-item ${isActive ? 'active' : ''}`}
                onClick={() => setActiveTab(item.id)}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <Icon size={18} color={isActive ? '#38BDF8' : '#94A3B8'} />
                  <span>{item.label}</span>
                </div>
                {item.badge !== undefined && item.badge > 0 && (
                  <span
                    style={{
                      background: 'var(--coral-loss)',
                      color: '#FFF',
                      fontSize: 10,
                      fontWeight: 900,
                      padding: '2px 7px',
                      borderRadius: 10
                    }}
                  >
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Sidebar User Card */}
        <div className="sidebar-user-card">
          <div className="avatar-circle" style={{ width: 40, height: 40, fontSize: 14 }}>
            PS
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 800, color: '#FFF', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {state.user.name}
            </div>
            <div style={{ fontSize: 11, color: '#94A3B8' }}>
              {state.user.doublesRating.toFixed(3)} Doubles
            </div>
          </div>
          <Shield size={16} color="#38BDF8" />
        </div>
      </aside>

      {/* Main Layout Area */}
      <div className="main-layout">
        {/* Top Header */}
        <header className="app-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span className="brand-pill" style={{ display: window.innerWidth >= 1024 ? 'none' : 'inline-block' }}>
              SUPR DUPR
            </span>
            <span className="header-title">{titles[activeTab]}</span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <button
              className="header-btn"
              title="MongoDB Ready Status"
              onClick={() => showToast('MongoDB Data Layer: Ready for URI.')}
            >
              <Settings2 size={16} />
            </button>
          </div>
        </header>

        {/* Content Area */}
        <main className="content-area">
          <InstallPrompt />

          {activeTab === 'profile' && (
            <AnalyticsScreen
              user={state.user}
              matches={state.matches}
              isDoubles={isDoubles}
              setIsDoubles={setIsDoubles}
            />
          )}

          {activeTab === 'log' && (
            <LogMatchScreen
              user={state.user}
              players={state.players}
              onSubmitMatch={submitMatch}
            />
          )}

          {activeTab === 'verify' && (
            <VerificationQueueScreen
              matches={state.matches}
              onConfirm={confirmMatch}
              onDispute={disputeMatch}
            />
          )}

          {activeTab === 'leaderboard' && (
            <LeaderboardScreen
              user={state.user}
              players={state.players}
              isDoubles={isDoubles}
            />
          )}

          {activeTab === 'courts' && (
            <CourtsScreen
              venues={state.venues}
              checkedInVenueId={checkedInVenueId}
              onToggleCheckIn={toggleCheckIn}
              showToast={showToast}
            />
          )}
        </main>
      </div>

      {/* Bottom Navigation (Mobile Only) */}
      <nav className="bottom-nav">
        {navItems.map(item => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              className={`nav-tab-item ${isActive ? 'active' : ''}`}
              onClick={() => setActiveTab(item.id)}
            >
              <Icon size={20} />
              {item.badge !== undefined && item.badge > 0 && (
                <span className="nav-badge">{item.badge}</span>
              )}
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}

export default App;
