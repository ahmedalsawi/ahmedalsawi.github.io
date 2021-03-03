---
title: "Web scraping with python"
date: 2019-06-02
toc: false
images:
tags:
  - web
---

This post is about the fetch and crawl of html pages using `requests` and `BeautifulSoup`

I came across an interesting forum and i was looking for posts with some keywords. The forum did have a search form but didn't support any kind of regex. I think it uses some kind OR'ing logic for search keywords and returns any post that has any of the words. It was built in early 00's using PHP, lucky for me. So, the approach was

- Format the search URL based on given keywords
- Fetch the search results and crawl the hits and fetch them
- Search for given patterns(including regex)

# Getting and parsing pages

`requests` is very easy way to get raw HTML pages

```python
url = "www.forum.com/search?q=something"
import requests

r = requests.get(url)
print(r.content)
```

Now we have the HTML in `r.content`, `BeautifulSoup` is used to parse HTML into something i can traverse with `find` and `findAll` methods. Below an example of parsing a list with CSS class `search1` and getting all links.

```python
from bs4 import BeautifulSoup
import requests

r = requests.get(new_page)

soup = BeautifulSoup(r.content, 'html5lib')
threads = soup.find('li', attrs = {'class':'search1'}).findAll('a', attrs = {'title':'View This Message'})
```

At this point, i have links to posts with attribute `href`, i can fetch the individual post pages, parse them and extract the raw text. well, the next step is just `re.search` and i am done.

```python
for thread in threads:

    r = requests.get(thread['href'])
    soup = BeautifulSoup(r.content, 'html5lib')

    posts = [p.findAll('div')[0].text for p in soup.findAll('div', attrs = {'class':'am_body_left'})]

```

# Useful libraries

- `requests_cache` to cache requests. very useful as this website is static.
- `argparse` to parse command line options and provide grep-like features.
- `logging` to control verbosity.
