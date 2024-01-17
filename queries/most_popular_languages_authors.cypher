//most popular languages authors
MATCH (a:Author)-[:WROTE]->(b: Book)-[EDITIONED_AS]->(p: Publication)-[:WRITTEN_IN]->(l:Language)
RETURN a.name AS `Author`, COUNT(DISTINCT l) AS languageCount
ORDER BY languageCount DESC LIMIT 20;

// no-index: 120ms
// index: 100ms