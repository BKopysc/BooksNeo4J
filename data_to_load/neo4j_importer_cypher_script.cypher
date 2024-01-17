:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'file:///', // Change this to the folder your script can access the files at.
  file_0: 'books_data.csv',
  file_1: 'adaptation_table_fixed.csv',
  file_2: 'ratings.csv',
  file_3: 'authors.csv',
  file_4: 'books_authors.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
//
// NOTE: The following constraint creation syntax is generated based on the current connected database version 5.15-aura.
CREATE CONSTRAINT `imp_uniq_Book_id` IF NOT EXISTS
FOR (n: `Book`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_Author_id` IF NOT EXISTS
FOR (n: `Author`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_Publication_isbn` IF NOT EXISTS
FOR (n: `Publication`)
REQUIRE (n.`isbn`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_Publisher_name` IF NOT EXISTS
FOR (n: `Publisher`)
REQUIRE (n.`name`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_Rating_id` IF NOT EXISTS
FOR (n: `Rating`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_Language_codeName` IF NOT EXISTS
FOR (n: `Language`)
REQUIRE (n.`codeName`) IS UNIQUE;
CREATE CONSTRAINT `imp_uniq_First Film_id` IF NOT EXISTS
FOR (n: `First Film`)
REQUIRE (n.`id`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`bookID` IN $idsToSkip AND NOT row.`bookID` IS NULL
CALL {
  WITH row
  MERGE (n: `Book` { `id`: row.`bookID` })
  SET n.`id` = row.`bookID`
  SET n.`title` = row.`title`
  SET n.`numOfPages` = toInteger(trim(row.`num_pages`))
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row
WHERE NOT row.`authorID` IN $idsToSkip AND NOT row.`authorID` IS NULL
CALL {
  WITH row
  MERGE (n: `Author` { `id`: row.`authorID` })
  SET n.`id` = row.`authorID`
  SET n.`name` = row.`authorName`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`isbn` IN $idsToSkip AND NOT row.`isbn` IS NULL
CALL {
  WITH row
  MERGE (n: `Publication` { `isbn`: row.`isbn` })
  SET n.`isbn` = row.`isbn`
  SET n.`isbn13` = row.`isbn13`
  // Your script contains the datetime datatype. Our app attempts to convert dates to ISO 8601 date format before passing them to the Cypher function.
  // This conversion cannot be done in a Cypher script load. Please ensure that your CSV file columns are in ISO 8601 date format to ensure equivalent loads.
  SET n.`publicationDate` = datetime(row.`publication_date`)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`publisher` IN $idsToSkip AND NOT row.`publisher` IS NULL
CALL {
  WITH row
  MERGE (n: `Publisher` { `name`: row.`publisher` })
  SET n.`name` = row.`publisher`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`ratingID` IN $idsToSkip AND NOT row.`ratingID` IS NULL
CALL {
  WITH row
  MERGE (n: `Rating` { `id`: row.`ratingID` })
  SET n.`id` = row.`ratingID`
  SET n.`averageRating` = toFloat(trim(row.`average_rating`))
  SET n.`ratingsCount` = toInteger(trim(row.`ratings_count`))
  SET n.`textReviewsCount` = toInteger(trim(row.`text_reviews_count`))
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`language_code` IN $idsToSkip AND NOT row.`language_code` IS NULL
CALL {
  WITH row
  MERGE (n: `Language` { `codeName`: row.`language_code` })
  SET n.`codeName` = row.`language_code`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`ID` IN $idsToSkip AND NOT row.`ID` IS NULL
CALL {
  WITH row
  MERGE (n: `First Film` { `id`: row.`ID` })
  SET n.`id` = row.`ID`
  SET n.`title` = row.`First film adaptation`
  SET n.`yearOfProduction` = toInteger(trim(row.`Film adaptation year`))
} IN TRANSACTIONS OF 10000 ROWS;


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Author` { `id`: row.`authorID` })
  MATCH (target: `Book` { `id`: row.`bookID` })
  MERGE (source)-[r: `WROTE`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Publisher` { `name`: row.`publisher` })
  MATCH (target: `Publication` { `isbn`: row.`isbn` })
  MERGE (source)-[r: `PUBLISHED`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Book` { `id`: row.`bookID` })
  MATCH (target: `Publication` { `isbn`: row.`isbn` })
  MERGE (source)-[r: `EDITIONED_AS`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Book` { `id`: row.`bookID` })
  MATCH (target: `Rating` { `id`: row.`ratingID` })
  MERGE (source)-[r: `RATED_AS`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Publication` { `isbn`: row.`isbn` })
  MATCH (target: `Language` { `codeName`: row.`language_code` })
  MERGE (source)-[r: `WRITTEN_IN`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;
