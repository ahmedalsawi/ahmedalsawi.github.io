---
title: "WE API reverse engineering"
date: 2020-08-29T21:39:25+02:00
tags:
  - web
---

# Background

My ISP has a "modern" web app using Angular and REST backend. that said, their website sucks because their login form breaks my password manager. So, I have to login manually every time.

Obviously, they don't have a documented API. so, i have to trace the xhr requests in the browser. This is a 3 hour journey to reverse engineer their login API including deepdive into their weird password encryption!

# requests session

I am using `requests` session because I wasn't sure what kind of cookies they are using and i wanted to focus on REST API.

```python
import requests
s = requests.Session()
```

# Login Endpoint

Starting with the login page `https://my.te.eg/#/home/signin`. I saw xhr `post` request on `https://api-my.te.eg/api/user/generatetoken?channelId=WEB_APP`. the request payload was

```json
(data = {
  "header": {
    "msisdn": "<PHONE NUMBER>",
    "locale": "En"
  },
  "body": {
    "password": "<SOME HASH>"
  }
})
```

okey, This is the login endpoint. But why is the password hashed?!

I guess they are not sending the password in plain text. which is an overkill considering it's all on SSL. Anyway, I circle back to that.

So, I tried `post` with that hash and phone number. but I got an authentication error

```json
{
  "header": {
    "responseMessage": "Your Session has been expired, please sign in to continue",
}
```

so, I went back to the browser for a deeper look at the login request/response. this time, i noticed the request header has `jwt`.

wat? This is the login request.why is there jwt?

I assumed that jwt was stored in local storage. and it was. It turns out that there was get request to another endpoint to generate a guest jwt which is needed for the login API. PARANOID much?

Anyway, quick get request to extract guest jwt.

```python
# Get initial JWT Tocken
r = s.get(TOKEN_API)
jwt = r.json()["body"]["jwt"]
```

I tried to login again. This time i sent the jwt in the headers.

```python
data = {
  "header": {
    "msisdn": "<PHONE NUMBER>",
    "locale": "En"
  },
  "body": {
    "password": "<SOME HASH>"
  }
}

headers = {
    "jwt": jwt
}
r = s.post(SIGN_API, json=data, headers=headers)
```

And It worked! Now i am logged in and I have a new auth jwt in the response.

# Hitting the information endpoints

Time to get information about my remaining quota this month which I always exceed :(

Beside the auth jwt, I know that requests needs customerId. so, I extracted that as well.

```python

customerId = r.json()["header"]["customerId"]
jwt = r.json()["body"]["jwt"]

```

Set the new jwt and data json for `freeunitusage` endpoint.

```python
headers = {
    "jwt": jwt
}

data = {
    "header": {
        "customerId": customerId,
        "msisdn": <PHONE NUMBER>,
        "locale": "En"
    },
    "body": {}
}

FREEUNITS_API = "https://api-my.te.eg/api/line/freeunitusage"

r = s.post(FREEUNITS_API, json=data, headers=headers)

print(r.json()["body"]["summarizedLineUsageList"][0]["freeAmount"])
```

# The Password hash

At this point, i have a working script but using the weird hash i got from the browser. How was that generated?

Initially i thought it's some kind of hash. well I was wrong. `hashid` failed to detect the hash type.

```bash
$ hashid HASH
Analyzing 'HASH'
[+] Unknown hash
```

Well, I was curios enough that i decided to trace frontend javascript to know what generated the hash. and i got lucky :)

## Step1 Set a breakpoint on XHR/fetch requests

I know that login form will generate the XHR request with hashed password. So, I set XHR breakpoint there.
![Example image](/xhr_bp.png)

## Step2 Login

now i have a breakpoint, i tried to login again in the browser

The browser stopped right before sending xhr. I went through the stack trace frame by frame until i found what i was looking for `signIn`.
![Example image](/angular-signin.png)

I guess this is login service called from angular login component.

going through `signin` javacript function. Ugh!
I finally saw it. Surprise! It wasn't a hash. it's AES.

![Example image](/aesService.png)

I looked into `aesService` object and it has the `key` and `iv` for AES-128.

Disclaimer: I don't know why they are encrypting password. I assume they have key on the backend to decrypt and hash.
but is the key fixed? is it the same for everyone? I don't know. but if it's, what is the point!?

## Encrypting the password

Now, I can use any AES implementation to encrypt my password before sending login request.
I found an example of AES encryption at [github][1]. I modified it a little to use variable `iv`.

```python
key = b"16 byte KEY"
iv = b"16 byte IV"

password_enc = AESCipher(key, iv).encrypt(args.password)
```

[1]: https://gist.github.com/wowkin2/a2b234c87290f6959c815d3c21336278
