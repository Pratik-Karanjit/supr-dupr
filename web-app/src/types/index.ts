// Types matching the mobile app data model

export interface Player {
  id: string;
  name: string;
  city: string;
  hub: string;
  singles: number;
  doubles: number;
  rel: number;
  matches: number;
  wins: number;
  losses: number;
}

export interface GameScore {
  t1: number;
  t2: number;
}

export interface Match {
  id: string;
  code: string;
  type: 'Singles' | 'Doubles';
  date: string;
  venue: string;
  team1: string;
  team2: string;
  winnerTeam: number;
  sets: GameScore[];
  loggedBy: string;
  status: 'pending' | 'confirmed' | 'disputed';
  delta: number;
}

export interface UserProfile {
  id: string;
  name: string;
  city: string;
  homeHub: string;
  singlesRating: number;
  doublesRating: number;
  reliability: number;
  matchesPlayed: number;
  wins: number;
  losses: number;
  history: RatingHistoryPoint[];
}

export interface RatingHistoryPoint {
  date: string;
  rating: number;
  delta: number;
}

export interface Venue {
  id: string;
  name: string;
  location: string;
  courts: number;
  surface: string;
  hours: string;
  phone: string;
  instagram: string;
  instagramHandle: string;
  whatsapp?: string;
  comingSoon?: boolean;
}

export interface RatingCalcResult {
  t1Avg: number;
  t2Avg: number;
  expectedT1Prob: number;
  actualOutcome: number;
  winnerTeam: number;
  pdFactor: number;
  dynamicK: number;
  delta: number;
  t1Games: number;
  t2Games: number;
  t1Pts: number;
  t2Pts: number;
  avgRel: number;
}

export type TabId = 'profile' | 'log' | 'verify' | 'leaderboard' | 'courts';
