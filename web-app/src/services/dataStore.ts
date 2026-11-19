import type { UserProfile, Player, Match, Venue } from '../types';

// MongoDB-ready data layer with localStorage caching.
const STORAGE_KEY = 'supr_dupr_state_v2';

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
      homeHub: 'The Pickleball Nepal (Boudha)',
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
      { id: 'p_aayush', name: 'Aayush Karki', city: 'Pokhara', hub: 'DinkHaus (Pokhara Lakeside)', singles: 4.350, doubles: 4.410, rel: 95, matches: 42, wins: 33, losses: 9 },
      { id: 'p_rohan', name: 'Rohan Shrestha', city: 'Kathmandu', hub: 'The Flash Pickleball (Sukedhara)', singles: 4.120, doubles: 4.250, rel: 92, matches: 34, wins: 26, losses: 8 },
      { id: 'p_anjali', name: 'Anjali Tamang', city: 'Kathmandu', hub: 'The Pickleball Nepal (Boudha)', singles: 3.820, doubles: 3.910, rel: 88, matches: 24, wins: 17, losses: 7 },
      { id: 'p_bibek', name: 'Bibek Thapa', city: 'Lalitpur', hub: 'Picklepoint Nepal (Sitakwa Marg)', singles: 3.650, doubles: 3.780, rel: 80, matches: 19, wins: 12, losses: 7 },
      { id: 'p_sneha', name: 'Sneha Shakya', city: 'Kathmandu', hub: 'BoxArena (Tangal)', singles: 3.250, doubles: 3.420, rel: 75, matches: 15, wins: 9, losses: 6 },
      { id: 'p_sujan', name: 'Sujan Maharjan', city: 'Kathmandu', hub: 'Pick & Sip (Kamal Pokhari)', singles: 2.850, doubles: 2.920, rel: 60, matches: 8, wins: 4, losses: 4 }
    ],
    matches: [
      {
        id: 'm_102', code: 'NPR-834', type: 'Singles', date: 'Yesterday',
        venue: 'The Pickleball Nepal (Boudha)', team1: 'Anjali Tamang', team2: 'Pratik Sharma',
        winnerTeam: 1, sets: [{ t1: 11, t2: 9 }, { t1: 8, t2: 11 }, { t1: 11, t2: 7 }],
        loggedBy: 'Anjali Tamang', status: 'pending', delta: -0.026
      },
      {
        id: 'm_101', code: 'NPR-712', type: 'Doubles', date: 'Nov 14',
        venue: 'The Flash Pickleball (Sukedhara)', team1: 'Pratik Sharma & Rohan Shrestha', team2: 'Bibek Thapa & Sujan Maharjan',
        winnerTeam: 1, sets: [{ t1: 11, t2: 8 }, { t1: 11, t2: 5 }],
        loggedBy: 'Pratik Sharma', status: 'confirmed', delta: 0.125
      },
      {
        id: 'm_100', code: 'NPR-650', type: 'Doubles', date: 'Nov 08',
        venue: 'Picklepoint Nepal (Sitakwa Marg)', team1: 'Bibek Thapa & Sandeep Shah', team2: 'Pratik Sharma & Anjali Tamang',
        winnerTeam: 1, sets: [{ t1: 11, t2: 8 }, { t1: 9, t2: 11 }, { t1: 11, t2: 7 }],
        loggedBy: 'Bibek Thapa', status: 'confirmed', delta: -0.060
      }
    ],
    venues: [
      {
        id: 'v1',
        name: 'The Pickleball Nepal',
        location: 'Boudha, Kathmandu',
        courts: 4,
        surface: 'Outdoor Regulation Cushion',
        hours: '06:00 AM - 09:30 PM',
        phone: '+9779801988899',
        instagram: 'https://www.instagram.com/thepickleballnepal/',
        instagramHandle: '@thepickleballnepal',
        whatsapp: '+9779801988899'
      },
      {
        id: 'v2',
        name: 'The Flash Pickleball Nepal',
        location: 'Sukedhara / Naxal, Kathmandu',
        courts: 4,
        surface: 'Pro Acrylic Outdoor Hardcourt',
        hours: '06:00 AM - 10:00 PM',
        phone: '+9779813000555',
        instagram: 'https://www.instagram.com/theflashpickleball/',
        instagramHandle: '@theflashpickleball',
        whatsapp: '+9779813000555'
      },
      {
        id: 'v3',
        name: 'Picklepoint Nepal',
        location: 'Sitakwa Marg, Lalitpur',
        courts: 3,
        surface: 'Hardcourt with Night Floodlights',
        hours: '06:30 AM - 09:00 PM',
        phone: '+9779841234567',
        instagram: 'https://www.instagram.com/picklepoint.np/',
        instagramHandle: '@picklepoint.np',
        whatsapp: '+9779841234567'
      },
      {
        id: 'v4',
        name: 'BoxArena',
        location: 'Tangal, Kathmandu',
        courts: 2,
        surface: 'Indoor Covered Multi-Sport',
        hours: '06:00 AM - 10:00 PM',
        phone: '+9779802345678',
        instagram: 'https://www.instagram.com/boxarena.np/',
        instagramHandle: '@boxarena.np'
      },
      {
        id: 'v5',
        name: 'Pick & Sip',
        location: 'Kamal Pokhari / Hattisar, Kathmandu',
        courts: 2,
        surface: 'Rooftop Sports Turf & Lounge',
        hours: '07:00 AM - 10:00 PM',
        phone: '+9779851122334',
        instagram: 'https://www.instagram.com/pickandsip.np/',
        instagramHandle: '@pickandsip.np'
      },
      {
        id: 'v6',
        name: 'DinkHaus (Meerkat Park)',
        location: 'Street-17, Lakeside, Pokhara',
        courts: 3,
        surface: 'Lakeside Scenic Regulation Court',
        hours: '06:30 AM - 09:00 PM',
        phone: '+9779861002233',
        instagram: 'https://www.instagram.com/meerkat_park/',
        instagramHandle: '@meerkat_park',
        whatsapp: '+9779861002233'
      },
      {
        id: 'v7',
        name: 'ANLTA Complex (Tennis & Pickleball)',
        location: 'Satdobato, Lalitpur',
        courts: 6,
        surface: 'Championship Outdoor Hardcourt',
        hours: '06:00 AM - 08:30 PM',
        phone: '+977015522222',
        instagram: 'https://www.instagram.com/pickleballassociationnepal/',
        instagramHandle: '@pickleballassociationnepal'
      }
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
