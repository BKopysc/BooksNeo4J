//author-index-test
Match (a:Author) WHERE a.name = "J.K. Rowling" return a LIMIT 20 
//NO-INDEX 15 ms
//index 4ms