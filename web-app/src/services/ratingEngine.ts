import type { GameScore, RatingCalcResult, Player, UserProfile } from '../types';

const BASE_K = 0.160;

function getPlayerRating(
  user: UserProfile,
  players: Player[],
  name: string,
  isDoubles: boolean
): number {
  if (name === user.name || name.includes(user.name)) {
    return isDoubles ? user.doublesRating : user.singlesRating;
  }
  const p = players.find(pl => pl.name === name);
  if (!p) return 3.5;
  return isDoubles ? p.doubles : p.singles;
}

function getPlayerReliability(
  user: UserProfile,
  players: Player[],
  name: string
): number {
  if (name === user.name || name.includes(user.name)) {
    return user.reliability;
  }
  const p = players.find(pl => pl.name === name);
  return p ? p.rel : 50;
}

export function calculateMatchEngine(
  user: UserProfile,
  players: Player[],
  isDoubles: boolean,
  partnerName: string | null,
  op1Name: string,
  op2Name: string | null,
  sets: GameScore[]
): RatingCalcResult {
  const userRating = getPlayerRating(user, players, user.name, isDoubles);
  const userRel = user.reliability;

  const t1Ratings: number[] = [userRating];
  const t1Rels: number[] = [userRel];

  if (isDoubles && partnerName) {
    t1Ratings.push(getPlayerRating(user, players, partnerName, true));
    t1Rels.push(getPlayerReliability(user, players, partnerName));
  }

  const t2Ratings: number[] = [getPlayerRating(user, players, op1Name, isDoubles)];
  const t2Rels: number[] = [getPlayerReliability(user, players, op1Name)];

  if (isDoubles && op2Name) {
    t2Ratings.push(getPlayerRating(user, players, op2Name, true));
    t2Rels.push(getPlayerReliability(user, players, op2Name));
  }

  const t1Avg = t1Ratings.reduce((a, b) => a + b, 0) / t1Ratings.length;
  const t2Avg = t2Ratings.reduce((a, b) => a + b, 0) / t2Ratings.length;
  const t1AvgRel = t1Rels.reduce((a, b) => a + b, 0) / t1Rels.length;
  const t2AvgRel = t2Rels.reduce((a, b) => a + b, 0) / t2Rels.length;

  // Step 1: Logistic Expected Win Probability (scale divisor 0.75 for 1.0–6.0 range)
  const diff = t1Avg - t2Avg;
  const expectedT1 = 1.0 / (1.0 + Math.pow(10, -diff / 0.75));

  // Step 2: Actual Match Outcome
  let t1Games = 0, t2Games = 0, t1Pts = 0, t2Pts = 0;
  sets.forEach(s => {
    if (s.t1 > s.t2) t1Games++;
    else if (s.t2 > s.t1) t2Games++;
    t1Pts += s.t1;
    t2Pts += s.t2;
  });
  const actualOutcome = t1Games > t2Games ? 1.0 : (t1Games < t2Games ? 0.0 : 0.5);

  // Step 3: Point Differential Factor (0.75 → 1.35)
  const totalPts = t1Pts + t2Pts;
  const ptDiffRatio = totalPts > 0 ? Math.abs(t1Pts - t2Pts) / totalPts : 0;
  const pdFactor = 0.75 + (ptDiffRatio * 0.60);

  // Step 4: Dynamic K-Factor based on Reliability Index
  const avgRel = Math.round((t1AvgRel + t2AvgRel) / 2);
  let dynamicK = BASE_K;
  if (avgRel < 40) dynamicK = BASE_K * 1.50;
  else if (avgRel < 75) dynamicK = BASE_K * 1.15;
  else dynamicK = BASE_K * 0.90;

  // Step 5: Raw Delta with ±0.020 floor guarantee
  let rawDelta = dynamicK * (actualOutcome - expectedT1) * pdFactor;
  if (actualOutcome === 1.0 && rawDelta < 0.02) rawDelta = 0.02;
  if (actualOutcome === 0.0 && rawDelta > -0.02) rawDelta = -0.02;

  const delta = Math.round(rawDelta * 1000) / 1000;

  return {
    t1Avg: Math.round(t1Avg * 1000) / 1000,
    t2Avg: Math.round(t2Avg * 1000) / 1000,
    expectedT1Prob: Math.round(expectedT1 * 100),
    actualOutcome,
    winnerTeam: t1Games >= t2Games ? 1 : 2,
    pdFactor: Math.round(pdFactor * 100) / 100,
    dynamicK: Math.round(dynamicK * 1000) / 1000,
    delta,
    t1Games,
    t2Games,
    t1Pts,
    t2Pts,
    avgRel
  };
}

export function calculateNewReliability(matchesCount: number): number {
  if (matchesCount <= 1) return 25;
  if (matchesCount <= 3) return 40;
  if (matchesCount <= 6) return 60;
  if (matchesCount <= 10) return 80;
  if (matchesCount <= 15) return 92;
  return Math.min(100, 92 + (matchesCount - 15));
}
