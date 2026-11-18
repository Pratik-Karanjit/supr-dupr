import type { UserProfile, Player, Match, Venue } from '../types';

// MongoDB-ready data layer. Currently uses localStorage.
// When MongoDB is connected, replace load/save with API calls.

const STORAGE_KEY = 'supr_dupr_state';

export interface AppState {
  user: UserProfile;
  players: Player[];
  matches: Match[];
  venues: Venue[];
}

export function getDefaultState(): AppState {
  return {
    user: {
      id: 'user_pratik',
      name: 'Pratik Sharma',
      city: 'Kathmandu',
      homeHub: 'Tiptoe Pickleball Club (Sanepa)',
      singlesRating: 3.420,
      doublesRating: 3.585,
      reliability: 84,
      matchesPlayed: 14,
      wins: 10,
      losses: 4,
      history: [
        { date: 'Oct 18', rating: 3.100, delta: 0 },
        { date: 'Oct 26', rating: 3.240, delta: 0.140 },
        { date: 'Nov 02', rating: 3.310, delta: 0.070 },
        { date: 'Nov 08', rating: 3.250, delta: -0.060 },
        { date: 'Nov 14', rating: 3.585, delta: 0.335 }
      ]
    },
    players: [
      { id: 'p_aayush', name: 'Aayush Karki', city: 'Pokhara', hub: 'Lakeside Center', singles: 4.350, doubles: 4.410, rel: 95, matches: 42, wins: 33, losses: 9 },
      { id: 'p_rohan', name: 'Rohan Shrestha', city: 'Kathmandu', hub: 'Tiptoe Club (Sanepa)', singles: 4.120, doubles: 4.250, rel: 92, matches: 34, wins: 26, losses: 8 },
      { id: 'p_anjali', name: 'Anjali Tamang', city: 'Kathmandu', hub: 'Boudha Arena', singles: 3.820, doubles: 3.910, rel: 88, matches: 24, wins: 17, losses: 7 },
      { id: 'p_bibek', name: 'Bibek Thapa', city: 'Lalitpur', hub: 'Jhamsikhel Hub', singles: 3.650, doubles: 3.780, rel: 80, matches: 19, wins: 12, losses: 7 },
      { id: 'p_sneha', name: 'Sneha Shakya', city: 'Kathmandu', hub: 'Dunkmandu Court', singles: 3.250, doubles: 3.420, rel: 75, matches: 15, wins: 9, losses: 6 },
      { id: 'p_sujan', name: 'Sujan Maharjan', city: 'Kathmandu', hub: 'Baluwatar Smash', singles: 2.850, doubles: 2.920, rel: 60, matches: 8, wins: 4, losses: 4 }
    ],
    matches: [
      {
        id: 'm_102', code: 'NPR-834', type: 'Singles', date: 'Yesterday',
        venue: 'Boudha Pickleball Arena', team1: 'Anjali Tamang', team2: 'Pratik Sharma',
        winnerTeam: 1, sets: [{ t1: 11, t2: 9 }, { t1: 8, t2: 11 }, { t1: 11, t2: 7 }],
        loggedBy: 'Anjali Tamang', status: 'pending', delta: -0.026
      },
      {
        id: 'm_101', code: 'NPR-712', type: 'Doubles', date: 'Nov 14',
        venue: 'Tiptoe Pickleball Club (Sanepa)', team1: 'Pratik Sharma & Rohan Shrestha', team2: 'Bibek Thapa & Sujan Maharjan',
        winnerTeam: 1, sets: [{ t1: 11, t2: 8 }, { t1: 11, t2: 5 }],
        loggedBy: 'Pratik Sharma', status: 'confirmed', delta: 0.125
      },
      {
        id: 'm_100', code: 'NPR-650', type: 'Doubles', date: 'Nov 08',
        venue: 'Jhamsikhel Sports Hub', team1: 'Bibek Thapa & Sandeep Shah', team2: 'Pratik Sharma & Anjali Tamang',
        winnerTeam: 1, sets: [{ t1: 11, t2: 8 }, { t1: 9, t2: 11 }, { t1: 11, t2: 7 }],
        loggedBy: 'Bibek Thapa', status: 'confirmed', delta: -0.060
      }
    ],
    venues: [
      { id: 'v1', name: 'Tiptoe Pickleball Club', location: 'Sanepa, Lalitpur', courts: 4, surface: 'Cushion Acrylic', hours: '06:00 AM - 09:30 PM', active: 8, phone: '+977-9801234567' },
      { id: 'v2', name: 'Boudha Pickleball Arena', location: 'Boudha, Kathmandu', courts: 3, surface: 'Outdoor Polymer', hours: '06:30 AM - 08:00 PM', active: 6, phone: '+977-9812345678' },
      { id: 'v3', name: 'Dunkmandu Sports Hub', location: 'Chuchepati, Kathmandu', courts: 2, surface: 'Indoor Maple Wood', hours: '07:00 AM - 10:00 PM', active: 4, phone: '+977-9841238910' },
      { id: 'v4', name: 'Jhamsikhel Pickleball', location: 'Jhamsikhel, Lalitpur', courts: 2, surface: 'Hardcourt', hours: '06:00 AM - 08:30 PM', active: 5, phone: '+977-9851122334' },
      { id: 'v5', name: 'Lakeside Pickleball Center', location: 'Lakeside, Pokhara', courts: 4, surface: 'Scenic Hardcourt', hours: '06:00 AM - 09:00 PM', active: 11, phone: '+977-9861002233' }
    ]
  };
}

export function loadState(): AppState {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) return JSON.parse(stored);
  } catch { /* fall through */ }
  return getDefaultState();
}

export function saveState(state: AppState): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch { /* silent */ }
}

export function resetState(): AppState {
  localStorage.removeItem(STORAGE_KEY);
  return getDefaultState();
}
