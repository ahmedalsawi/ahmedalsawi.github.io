---
title: "Setup Git without server"
date: 2020-01-30
toc: false
images:
tags:
  - git
  - IT
---

I recently had to setup a git repo on nfs path. So, there are the steps i used to setup it up (and Gotcha)

To do that, *bare* repo must be used. basically, bare repo is shared repo. You can't work directly on it because it doesn't have the source code. It contains whatever *.git* has.

Create bare repo

```bash
git init --bare myrepo.git
```

Then set your remote to the bare repo.

```bash
git remote add origin /path/to/repos/myrepo.git
```

to clone the repo

```bash
git clone /path/to/repos/myrepo.git
```


# Gotcha
It's very easy, Right? Not. when you share that repo, people will start seeing permissions errors.

I found two solutions

### Solution 1

Adding `--shared` while creating the repo
```
git init --bare --shared myrepo.git
```

### Solution 2
manually fixing permission on directories. i found that at [link](https://blog.christophersmart.com/2014/01/10/permanently-fixing-permissions-on-a-shared-git-repo/)


```bash
chown -Rf root:git /path/to/bare/git/repo
cd /path/to/bare/git/repo
git config core.sharedRepository group
find /path/to/bare/git/repo -type f | xargs chmod 664
find /path/to/bare/git/repo -type d | xargs chmod 775
find /path/to/bare/git/repo -type d | xargs chmod g+s
```