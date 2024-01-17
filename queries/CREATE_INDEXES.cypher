// CREATE INDEXES
//Text index for author name
CREATE TEXT INDEX author_name_text_index FOR (a:Author) on (a.name);
//Text index for book title
CREATE TEXT INDEX book_title_text_index FOR (b:Book) on (b.title);
//Range index for Rating
CREATE INDEX rating_average_range_index FOR (r:Rating) ON (r.averageRating);


