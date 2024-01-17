//jk rowling query
Match path = (b:Book)<-[:WROTE]-(a:Author) WHERE a.name = "J.K. Rowling" RETURN path