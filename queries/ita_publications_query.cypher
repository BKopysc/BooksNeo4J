//ita publications query
Match path = (b:Book)-[:EDITIONED_AS]->(p:Publication)-[:WRITTEN_IN]->(l:Language)
WHERE l.codeName = "ita" RETURN path