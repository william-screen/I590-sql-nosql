// Delete the entire database
// ------------------------------------------------------------
MATCH (n) DETACH DELETE n;

// Create contraints on ATP Tour Series and Tournaments
// ------------------------------------------------------------
CREATE CONSTRAINT ON (series:Series) ASSERT series.name IS UNIQUE;
CREATE CONSTRAINT ON (tournament:Tournament) ASSERT tournament.name IS UNIQUE;

// Load ATP Tour Series and Tournament data
// ------------------------------------------------------------
LOAD CSV WITH HEADERS 
FROM "https://raw.githubusercontent.com/william-screen/I590-sql-nosql/master/atp_tour_2016.csv" AS line
WITH DISTINCT line, SPLIT(line.Date, '/') AS date

// Create root node (parent organization)
MERGE (atptour:ATPTour { name : "ATP Tour", year: date[2] })

// Create ATP Tour Series nodes
MERGE (series:Series { name:line.Series, year: date[2] })

// Create Tournament nodes
MERGE (tournament:Tournament { name:line.Tournament, location: line.Location, year: date[2], court: line.Court, surface: line.Surface })

// Create relationship between parent organization and tournament series
MERGE (atptour)-[:governs_tournament_series]->(series)

// Create relationship between tournament series and the tournament
MERGE (series)-[:manages_tournaments]->(tournament);


// Load ATP Tour Tournament Nodes (for brevity only show final rounds)
// ------------------------------------------------------------
LOAD CSV WITH HEADERS 
FROM "https://raw.githubusercontent.com/william-screen/I590-sql-nosql/master/atp_tour_2016.csv" AS line
WITH DISTINCT line, SPLIT(line.Date, '/') AS date
WHERE line.Round = 'The Final'

// Create Tournament rounds 
MATCH (tournament:Tournament)
WHERE tournament.name = line.Tournament AND tournament.year = date[2] 
MERGE (round:Round {name: line.Round, tournament:line.Tournament, year: date[2], winner: line.Winner, loser: line.Loser, winner_rank: line.WRank, loser_rank:line.LRank, winner_points: line.WPts, loser_points: line.LPts})

// Create relationship between tournament and rounds
MERGE (tournament)-[:schedules_rounds]->(round);

// Load ATP Tour Winning Player Nodes
// ------------------------------------------------------------
LOAD CSV WITH HEADERS 
FROM "https://raw.githubusercontent.com/william-screen/I590-sql-nosql/master/atp_tour_2016.csv" AS line
WITH DISTINCT line, SPLIT(line.Date, '/') AS date
WHERE line.Round = 'The Final'

// Create Player nodes
MATCH (tournament:Tournament),(round:Round)
WHERE tournament.year = round.year AND tournament.name = round.tournament AND round.name = line.Round AND round.winner = line.Winner AND round.winner_rank = line.WRank AND round.winner_points = line.WPts
MERGE(winner:Player { name:round.winner, tournament:round.tournament, year: round.year, round: round.name, rank: round.winner_rank, points: line.WPts})

// Create relationship between round and winning player
MERGE (round)-[:players_compete]->(winner);

// Load ATP Tour Losing Player Nodes
// ------------------------------------------------------------
LOAD CSV WITH HEADERS 
FROM "https://raw.githubusercontent.com/william-screen/I590-sql-nosql/master/atp_tour_2016.csv" AS line
WITH DISTINCT line, SPLIT(line.Date, '/') AS date
WHERE line.Round = 'The Final'

MATCH (tournament:Tournament),(round:Round)
WHERE tournament.year = round.year AND tournament.name = round.tournament AND round.name = line.Round AND round.loser = line.Loser AND round.loser_rank = line.LRank AND round.loser_points = line.LPts
MERGE(loser:Player { name:round.loser, tournament:round.tournament, year: round.year, round: round.name, rank: round.loser_rank, points: line.LPts})

// Create relationship between round and losing player
MERGE (round)-[:players_compete]->(loser);