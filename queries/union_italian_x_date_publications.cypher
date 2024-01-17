//union: italian x date publications
MATCH (a:Author)-[:WROTE]->(b:Book)-[:EDITIONED_AS]->(p:Publication)-[:WRITTEN_IN]->(l:Language)
WHERE l.codeName = "ita"
RETURN a
LIMIT 5
UNION
MATCH (a:Author)-[:WROTE]->(b:Book)-[:EDITIONED_AS]->(p:Publication)
WHERE p.publicationDate > datetime({year:1980,month:1}) AND p.publicationDate < datetime({year:1981,month:1})
RETURN a
LIMIT 5;

// no-index: 5ms
// index: 5ms