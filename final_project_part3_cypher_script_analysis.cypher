// Base query to return tournament, players, and ranking
// ------------------------------------------------------------
MATCH (n:Round)
WITH n
RETURN n.tournament, n.winner, toInteger(n.winner_rank), n.loser, toInteger(n.loser_rank)
ORDER BY n.tournament

// What are the min, avg, max, and std of ranks for all matches 
// ------------------------------------------------------------
MATCH (n:Round)
WITH n
RETURN min(abs(toInteger(n.loser_rank) - toInteger(n.winner_rank))) AS Rank_Diff_Min,
avg(abs(toInteger(n.loser_rank) - toInteger(n.winner_rank))) AS Rank_Diff_Avg,
max(abs(toInteger(n.loser_rank) - toInteger(n.winner_rank))) AS Rank_Diff_Max,
stDev(abs(toInteger(n.loser_rank) - toInteger(n.winner_rank))) AS Rank_Diff_stDev

// What is the biggest upset in terms of ranking?
// ------------------------------------------------------------
MATCH (n:Round)
WHERE toInteger(n.loser_rank) < toInteger(n.winner_rank)
WITH n
ORDER BY abs(toInteger(n.loser_rank) - toInteger(n.winner_rank)) DESC
RETURN n.tournament as Tournament, n.winner as Winner, toInteger(n.winner_rank) as Winner_Rank, n.loser as Finalist, toInteger(n.loser_rank) as Finalist_Rank, abs(toInteger(n.loser_rank) - toInteger(n.winner_rank)) AS Rank_Diff

// Which players have reached to most final rounds?
// ------------------------------------------------------------
MATCH (n:Player)
RETURN n.name AS Player, count(n.name) AS num_finals
ORDER BY num_finals DESC
LIMIT 10

// Which player have the most championship wins
// ------------------------------------------------------------
MATCH (round:Round)-[:players_compete]->(player:Player)
WHERE player.name IN [round.winner]
RETURN player.name as Player, count(round.winner) as Num_Wins
ORDER BY Num_Wins DESC
LIMIT 10

MATCH (tournament:Tournament)-[:schedules_rounds]->(round:Round), (round:Round)-[:players_compete]->(player:Player)
WHERE round.winner IN ["Djokovic N."]
RETURN round, player, tournament