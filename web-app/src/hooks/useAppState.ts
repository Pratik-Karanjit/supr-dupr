import { useState, useCallback } from 'react';
import type { AppState } from '../services/dataStore';
import { loadState, saveState } from '../services/dataStore';
import type { TabId, Match, GameScore } from '../types';
import { calculateMatchEngine, calculateNewReliability } from '../services/ratingEngine';

export function useAppState() {
  const [state, setState] = useState<AppState>(loadState);
  const [activeTab, setActiveTab] = useState<TabId>('profile');
  const [isDoubles, setIsDoubles] = useState(true);
  const [checkedInVenueId, setCheckedInVenueId] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const persist = useCallback((next: AppState) => {
    setState(next);
    saveState(next);
  }, []);

  const showToast = useCallback((msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  }, []);

  const submitMatch = useCallback((
    logIsDoubles: boolean, partner: string, op1: string, op2: string, venue: string, sets: GameScore[]
  ) => {
    const calc = calculateMatchEngine(state.user, state.players, logIsDoubles, partner, op1, op2, sets);
    const code = 'NPR-' + Math.floor(100 + Math.random() * 900);
    const newMatch: Match = {
      id: 'm_' + Date.now(), code, type: logIsDoubles ? 'Doubles' : 'Singles', date: 'Today', venue,
      team1: logIsDoubles ? `Pratik Sharma & ${partner}` : 'Pratik Sharma',
      team2: logIsDoubles ? `${op1} & ${op2}` : op1,
      winnerTeam: calc.winnerTeam, sets, loggedBy: 'Pratik Sharma', status: 'pending', delta: calc.delta
    };
    persist({ ...state, matches: [newMatch, ...state.matches] });
    showToast(`Match ${code} logged with ${calc.delta > 0 ? '+' : ''}${calc.delta.toFixed(3)} SUPR forecast!`);
    setActiveTab('verify');
  }, [state, persist, showToast]);

  const confirmMatch = useCallback((id: string) => {
    const match = state.matches.find(m => m.id === id);
    if (!match) return;
    const isD = match.type === 'Doubles';
    const user = { ...state.user };

    if (isD) user.doublesRating = +(user.doublesRating + match.delta).toFixed(3);
    else user.singlesRating = +(user.singlesRating + match.delta).toFixed(3);

    user.matchesPlayed++;
    if (match.winnerTeam === 1) user.wins++; else user.losses++;
    user.reliability = calculateNewReliability(user.matchesPlayed);
    user.history = [...user.history, { date: 'Today', rating: isD ? user.doublesRating : user.singlesRating, delta: match.delta }];

    const matches = state.matches.map(m => m.id === id ? { ...m, status: 'confirmed' as const } : m);
    persist({ ...state, user, matches });
    showToast(`Match ${match.code} confirmed! ${isD ? 'Doubles' : 'Singles'} → ${(isD ? user.doublesRating : user.singlesRating).toFixed(3)}.`);
  }, [state, persist, showToast]);

  const disputeMatch = useCallback((id: string) => {
    persist({ ...state, matches: state.matches.filter(m => m.id !== id) });
    showToast('Match disputed and flagged for arbitration.');
  }, [state, persist, showToast]);

  const toggleCheckIn = useCallback((venueId: string, name: string) => {
    if (checkedInVenueId === venueId) { setCheckedInVenueId(null); showToast(`Checked out of ${name}.`); }
    else { setCheckedInVenueId(venueId); showToast(`Checked in at ${name}!`); }
  }, [checkedInVenueId, showToast]);

  return { state, activeTab, setActiveTab, isDoubles, setIsDoubles, checkedInVenueId, toast, showToast, submitMatch, confirmMatch, disputeMatch, toggleCheckIn };
}
