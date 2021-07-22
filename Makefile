COMMIT_MESSAGE := $(shell date +%Y-%m-%d@%H:%M)
TAG := $(shell date +%y.%m.%d)

SHELL=/bin/bash

.DEFAULT_GOAL := publish

setup:
	gpgconf --kill gpg-agent
	rm -rf ~/.gnupg
	gpg-agent --homedir "${GNUPGHOME:-$HOME/.gnupg}" --daemon
	gpg --import "$(GPG_KEY)"
	git config --global user.signingKey $(gpg --list-secret-keys --keyid-format long | awk -F/ '/^sec/ {print $2}' | awk '{print $1}')
	git config --global commit.gpgSign true

prerequisites:
	mdl --version >/dev/null
	shellcheck --version >/dev/null
	git --version >/dev/null
	gpg --list-keys >/dev/null
	gpg --list-secret-keys >/dev/null
	git pull

lint:
	find . -type f -name "*.md" -exec mdl -r ~MD013 {} +

check: prerequisites lint

commit:
	git add --all .
	git commit -S -m "$(COMMIT_MESSAGE)"
	git push

tag:
	if git tag -l --sort=v:refname | grep -q "$(TAG)" ; then git tag -d "$(TAG)" ; git push --delete origin "$(TAG)" ; fi
	git tag -a -m "$(TAG)" "$(TAG)" -s
	git push origin "$(TAG)"

publish: check commit tag

remove-tags:
	git tag --list | xargs git push --delete origin
	git tag --list | xargs git tag -d