//rating-index-test
MATCH p=(r:Rating)<-[:RATED_AS]-(b:Book)
WHERE r.averageRating > 4.5
return p
LIMIT 20

//No-index 4 ms
//index: 1ms