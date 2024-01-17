import pandas as pd
import csv
import datetime

books_data_csv = pd.read_csv('books_data.csv')

# Get the year from the publication_date
# "publication_date": "3/28/1993"
# Convert it to DateTime and update the column

for index, row in books_data_csv.iterrows():
    # Get the date
    date = row['publication_date']
    #conver to datetime with datetime
    #print(date)
    date_time = None
    try:
        date_time = datetime.datetime.strptime(date, "%m/%d/%Y")
    except ValueError:
        #remove two days from string
        split_date = date.split('/')
        split_date[1] = str(int(split_date[1]) - 1)
        date = '/'.join(split_date)
        date_time = datetime.datetime.strptime(date, "%m/%d/%Y")
    
    #update the column with date_time with T in the middle
    date_time = date_time.strftime("%Y-%m-%dT%H:%M:%S")
    books_data_csv.at[index, 'publication_date'] = date_time

# Save to csv with extra utf8 encoding
books_data_csv.to_csv('books_data_r.csv', encoding='utf-8-sig', index=False)
