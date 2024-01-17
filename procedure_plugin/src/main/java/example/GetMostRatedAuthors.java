package example;

import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Result;
import org.neo4j.graphdb.Transaction;
import org.neo4j.logging.Log;
import org.neo4j.procedure.Context;
import org.neo4j.procedure.Mode;
import org.neo4j.procedure.Procedure;
import org.neo4j.procedure.Name;

import java.util.stream.Stream;
import java.util.Map;
import java.util.List;
import java.util.stream.Collectors;

public class GetMostRatedAuthors {

    @Context
    public GraphDatabaseService db;

    @Context
    public Log log;

    @Procedure(name = "example.getMostRatedAuthors", mode = Mode.READ)
    public Stream<AuthorResult> getMostRatedAuthors(@Name("authorName") String authorName) {
        String query = "MATCH (a:Author {name: $authorName})-[:WROTE]->(b:Book)-[:RATED_AS]->(r:Rating) " +
                "WITH a, sum(r.ratingsCount) as allRatings, avg(r.averageRating) as avgRating " +
                "ORDER BY allRatings DESC LIMIT 100 " +
                "RETURN a.name AS authorName, allRatings, avgRating";
		
		List<AuthorResult> authorResults;
		
        try (Transaction tx = db.beginTx()) {
            Result result = tx.execute(query, Map.of("authorName", authorName));
			
            authorResults = result.stream()
							.map(AuthorResult::fromMap)
							.collect(Collectors.toList());
			tx.commit();
        } catch (Exception e){
			throw new RuntimeException("Query error",e);
		}

        return authorResults.stream();
    }

    public static class AuthorResult {
        public String authorName;
        public Long allRatings;
        public Double avgRating;

        public AuthorResult(String authorName, Long allRatings, Double avgRating) {
            this.authorName = authorName;
            this.allRatings = allRatings;
            this.avgRating = avgRating;
        }

        public static AuthorResult fromMap(Map<String, Object> map) {
            return new AuthorResult(
                    (String) map.get("authorName"),
                    (Long) map.get("allRatings"),
                    (Double) map.get("avgRating")
            );
        }
    }
}
