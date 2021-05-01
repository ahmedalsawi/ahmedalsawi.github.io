---
title: "Python Pep 503"
date: 2021-05-01T13:09:31+01:00
tags:
- Python
---

[pep 503][1] defines the python package repo api used py *pypi.org*. I thought it was fun to create small repo using Flask (to host Flask) :)

The spec require two urls 
- root url
- project url

root url return html listing available project page. the anchor tags has the following requirements

> The text of the anchor tag MUST be the name of the project and the href attribute MUST link to the URL for that particular project. 


```html
<!DOCTYPE html>
<html>
  <head>
    <meta name="pypi:repository-version" content="1.0">
    <title>Simple index</title>
  </head>
  <body>
<a href="/foo/">Foo</a>
</body>
</html>
```


the project url, returns  html with anchor tags for tar file name and href for the that tar.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta name="pypi:repository-version" content="1.0">
    <title>Links for Flask</title>
  </head>
  <body>
    <h1>Links for Flask</h1>
    <a href="/static/Foo-0.1.tar.gz">Flask-0.1.tar.gz</a><br/>
    </body>
</html>

```


# Full source code

```bash
pip3 install Foo --index-url  http://localhost:5000 -v
```

```python

import os
from flask import Flask, send_from_directory, send_file


app = Flask(__name__, static_url_path='')

@app.route('/static/<path:filename>')
def f(filename):
    root_dir = os.getcwd()
    print(root_dir, filename)
    return send_from_directory(os.path.join(root_dir), filename)

@app.route('/')
def home():
	return """
<!DOCTYPE html>
<html>
  <head>
    <meta name="pypi:repository-version" content="1.0">
    <title>Simple index</title>
  </head>
  <body>
<a href="/foo/">Foo</a>
</body>
</html>

"""
@app.route('/foo/')
def hello_world():
    return """
<!DOCTYPE html>
<html>
  <head>
    <meta name="pypi:repository-version" content="1.0">
    <title>Links for Flask</title>
  </head>
  <body>
    <h1>Links for Flask</h1>
    <a href="/static/Foo-0.1.tar.gz">Foo-0.1.tar.gz</a><br/>
    </body>
</html>
"""

app.run(debug=True)

```

[1]: https://www.python.org/dev/peps/pep-0503/
