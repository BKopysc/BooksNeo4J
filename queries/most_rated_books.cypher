//most rated books
MATCH (a:Author)-[w: WROTE]->(b:Book)-[r:RATED_AS]->(rr:Rating) WHERE rr.averageRating >= 4.6 AND rr.ratingsCount > 20000 RETURN a.name as `Author Name`,b.title as `Book title`, rr.ratingsCount as `Rating Count`, rr.averageRating as `Rating` ORDER BY rr.averageRating DESC

//no-index 8ms
//index 2ms