
# ---- Sample Data ----
'''
{
  "bookID": 27,
  "title": "Neither Here nor There: Travels in Europe",
  "authors": "Bill Bryson/Adam Hill",
  "average_rating": 3.86,
  "isbn": 380713802,
  "isbn13": {
    "$numberLong": "9780380713806"
  },
  "language_code": "eng",
  "  num_pages": 254,
  "ratings_count": 48701,
  "text_reviews_count": 2238,
  "publication_date": "3/28/1993",
  "publisher": "William Morrow Paperbacks"
}
'''
#import
import csv
import json
#pandas
import pandas as pd

#load csv
file_path = 'books.csv'
loaded_csv = pd.read_csv(file_path, encoding='utf-8', on_bad_lines='skip')

authors_data = None
rating_data = None

# Authors are in the format: "author1/author2/author3"
# We need to split them up and creates a new csv of authors with their unique ID
# Then we need to create new file books_authors.csv with bookID and authorID
# Book can have multiple authors

authors = set()
for index, row in loaded_csv.iterrows():
    authors.update(row['authors'].split('/'))

# Now we have a set of all authors, we need to create a new csv with authorID and authorName
# We can use the index of the set as the authorID
# We can use the value of the set as the authorName

authors_data = pd.DataFrame(authors, columns=['authorName'])
authors_data.index.name = 'authorID'
authors_data.to_csv('authors.csv', encoding='utf-8')

# Now we need to create a new csv with bookID and authorID
# Iterate through the original csv and for each row, split the authors by / and check the authorID
# Then create a new row with bookID and authorID in the new csv

books_authors_arr_dict = []

def get_books_author(bookID, authorID):
    return {
        'bookID': bookID,
        'authorID': authorID
    }

for index, row in loaded_csv.iterrows():
    authors = row['authors'].split('/')
    for author in authors:
        authorID = authors_data[authors_data['authorName'] == author].index[0]
        #concat instead of append
        books_authors_arr_dict.append(get_books_author(row['bookID'], authorID))

books_authors_data = pd.DataFrame(books_authors_arr_dict)
books_authors_data.to_csv('books_authors.csv', encoding='utf-8', index_label='id')

# Now create a new csv with bookID and ratingID
# Rating must contains the average_rating, ratings_count, text_reviews_count

rating_data = loaded_csv[['bookID', 'average_rating', 'ratings_count', 'text_reviews_count']]
rating_data.index.name = 'ratingID'
rating_data.to_csv('ratings.csv', encoding='utf-8')

# Drop collumn authors from books.csv
loaded_csv.drop(columns=['authors'], inplace=True)

# Drop rating collumns from books.csv
loaded_csv.drop(columns=['average_rating', 'ratings_count', 'text_reviews_count'], inplace=True)

# Save CSV to books_cleaned.csv
loaded_csv.to_csv('books_data.csv', encoding='utf-8', index=False)






