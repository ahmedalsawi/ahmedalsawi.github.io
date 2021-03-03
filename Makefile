all:
	echo "make love ~ war "

server:
	hugo server -D -F

build: clean
	hugo

deploy: clean build
	rsync -e "ssh -p 22" -P -rvzc  --delete public/ aalsawi@techiedeepdive.com:/home/aalsawi/techiedeepdive.com

github:
	git add .
	git commit -m "New posts/modifications"
	git push

clean:
	rm -rf public
