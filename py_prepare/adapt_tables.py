import pandas as pd
import csv

adaptation_csv = pd.read_csv('adaptation_table_fixed.csv', encoding='utf-8', on_bad_lines='skip', delimiter=';')
books_csv = pd.read_csv('books.csv', encoding='utf-8', on_bad_lines='skip')
authors_csv = pd.read_csv('authors.csv', encoding='utf-8', on_bad_lines='skip')
books_authors_csv = pd.read_csv('books_authors.csv', encoding='utf-8', on_bad_lines='skip')

# Adaptation sample:
'''
{
  "ID": 1,
  "FictionWork": "3 Assassins (グラスホッパー, Gurasuhoppā)",
  "FictionWorkAuthor": "Kōtarō Isaka",
  "Fiction work year": 2004,
  "First film adaptation": "Grasshopper",
  "Film adaptation year": 2015
}
'''

# Books sample:
'''
{
  "bookID": 1,
  "title": "Harry Potter and the Half-Blood Prince (Harry Potter  #6)",
  "isbn": 439785960,
  "isbn13": {
    "$numberLong": "9780439785969"
  },
  "language_code": "eng",
  "  num_pages": 652,
  "publication_date": "9/16/2006",
  "publisher": "Scholastic Inc."
}
'''

# Authors sample:
'''
{
  "authorID": 1,
  "authorName": "J.K. Rowling"
}
'''

# Books_Authors sample:
'''
{
  "bookID": 1,
  "authorID": 1
}
'''

# Loop through adaptation.csv and get the fiction work and fiction work author and ID
# Then loop through books.csv and check if the title and author match
# If they do, add the bookID to the adaptation.csv row

def get_book_dict_with_authors(bookName):
    bookID = None
    # Get bookID
    book_rows = books_csv.loc[books_csv['title'] == bookName]
    if len(book_rows) == 0:
        return None
    bookID = book_rows.iloc[0]['bookID']
    
    author_rows = books_authors_csv.loc[books_authors_csv['bookID'] == bookID]
    if len(author_rows) == 0:
        return None
    
    author_name_rows = authors_csv.loc[authors_csv['authorID'].isin(author_rows['authorID'])]

    author_names = author_name_rows['authorName'].tolist()
    return {
        'bookID': bookID,
        'bookName': bookName,
        'authorNames': author_names
    }

# Add new collumn to adaptation_csv
adaptation_csv['bookID'] = None

#display adaptation keys

print(adaptation_csv.keys())

for index, row in adaptation_csv.iterrows():
    bookName = row['FictionWork']
    bookDict = get_book_dict_with_authors(bookName)
    if(bookDict == None):
        continue
    
    authors_ctr = 0
    for authorName in bookDict['authorNames']:
        # if author name contains (without case sensitivity)
        if str(authorName).lower().find(str(row['FictionWorkAuthor']).lower()) != -1:
            authors_ctr += 1

    if authors_ctr == 0:
        continue

    adaptation_csv.at[index, 'bookID'] = bookDict['bookID']

# # If no bookID then set to -1
# adaptation_csv['bookID'] = adaptation_csv['bookID'].fillna(-1)
    
# Drop rows with no bookID
adaptation_csv = adaptation_csv.dropna(subset=['bookID'])

# Save to csv
adaptation_csv.to_csv('adaptations_bookId.csv', encoding='utf-8-sig', index=False)

