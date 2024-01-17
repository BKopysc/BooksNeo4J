//author-contains-index-test
Match (a:Author) WHERE a.name CONTAINS "David" return a LIMIT 20
//NO-INDEX 9ms
//Index 3ms