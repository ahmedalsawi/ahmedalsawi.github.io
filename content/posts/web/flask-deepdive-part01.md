---
title: "Flask Deep Dive Part1"
date: 2019-09-12
toc: false
images:
tags:
  - web
---


# Introduction
I have been playing around with flask for few weeks now. It's definitely leaner than Django but still there are some parts that look like  *black magic* (I am looking at you, g).

So, Starting with...

# Hello world

This looks like a good to place to start. This is the smallest functional flask app, I guess. 

Basically, there are two things happening here:

  * Route registration with `@app.rount`
  * Web Application with `app.run()`
  
```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello, World!"

if __name__ == '__main__':
   app.run(debug = True)

```

# Route registration
Let's start with app registration part.

`@app.route` defined in `flask/app.py` calls `add_url_rule`

```python
 def route(self, rule, **options):
        def decorator(f):
            endpoint = options.pop("endpoint", None)
            self.add_url_rule(rule, endpoint, f, **options)
            return f

        return decorator
```

and `add_url_rule`  takes f as `view_func` and register `rule` that maps that route to view_func

```python
    def add_url_rule(
        self,
        rule,
        endpoint=None,
        view_func=None,
        provide_automatic_options=None,
        **options
    ):
```

in the example above, `endpoint` is None, endpoint is set to `__name__` of the view_func 
```python
        if endpoint is None:
            endpoint = _endpoint_from_view_func(view_func)
```

```python
def _endpoint_from_view_func(view_func):
    assert view_func is not None, "expected view func if endpoint is not provided."
    return view_func.__name__
```

at this point we have rule as `/` and endpoint as `index`. Then, rule is used to create an object of `Rule` which takes `options` dict. and the newly created rule is added to `url_map`

To sum up, the following part registered url `/` to endpoint `index`

```python
        options["endpoint"] = endpoint
      ...
      ...
        rule = self.url_rule_class(rule, methods=methods, **options)
        rule.provide_automatic_options = provide_automatic_options

        self.url_map.add(rule)
```

and eventually, endpoint `index` is linked to the actual function `view_func` using view_functions

```python
            self.view_functions[endpoint] = view_func
```


# Web Application

For the second part, now that I know `view_functions` where the magic is, I can look for whoever doing lookup and  start from there.

But we know that flask is WSGI application. So, we can start with `__call__`. If you haven't heard about WSGI before, look into [pep333][1]. The important part:

> The Application/Framework Side
> The application object is simply a callable object that accepts two arguments. The term "object" should not be misconstrued as requiring an actual object instance: a function, method, class, or instance with a __call__ method are all acceptable for use as an application object. Application objects must be able to be invoked more than once, as virtually all servers/gateways (other than CGI) will make such repeated requests.

So, In `flask/app.py`, `__call__` is defined as

```python
    def __call__(self, environ, start_response):
        """The WSGI server calls the Flask application object as the
        WSGI application. This calls :meth:`wsgi_app` which can be
        wrapped to applying middleware."""
        return self.wsgi_app(environ, start_response)
```

In `wsgi_app`, 

```python
                response = self.full_dispatch_request()
   ...
   ...
            return response(environ, start_response)
```

in `full_dispatch_request`,

```python
    def full_dispatch_request(self):

                rv = self.dispatch_request()
```

In `dispatch_request`, `rule` is extract from the request and `rule.endpoint` is used to lookup the registered view from, wait for it, `view_functions`

```python
    def dispatch_request(self):

        return self.view_functions[rule.endpoint](**req.view_args)
```


[1]: https://www.python.org/dev/peps/pep-0333/