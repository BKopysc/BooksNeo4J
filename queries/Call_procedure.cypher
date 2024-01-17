//Call procedure
MATCH (a:Author)
CALL example.getMostRatedAuthors(a.name)
YIELD  authorName, allRatings, avgRating
RETURN authorName, allRatings, avgRating
ORDER BY allRatings DESC