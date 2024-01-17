//poor books adaptations
MATCH (r:Rating)<-[:RATED_AS]-(b: Book)<-[ad:ADAPTED]-(f:`First Film`)
WHERE f.yearOfProduction > 2000
AND r.averageRating < 3.5

MATCH (a:Author)-[: WROTE]->(b)
WHERE b = b

RETURN a, b, f AS adaptation
// no-index 8ms
// index:2ms