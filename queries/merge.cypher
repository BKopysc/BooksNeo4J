//merge
MATCH (a:Author)-[:WROTE]->(b:Book)<-[:ADAPTED]-(f:`First Film`)
WITH a, COUNT(a) as ct
WHERE ct > 3
MERGE (popularAdaptedAuthor: PopularAdaptedAuthor {name: a.name, numOfAdaptations: ct})
RETURN popularAdaptedAuthor
LIMIT 20