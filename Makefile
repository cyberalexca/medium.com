COMMIT_MESSAGE := $(shell date +%Y-%m-%d@%H:%M)
TAG := $(shell date +%y.%m.%d)

SHELL=/bin/bash

.DEFAULT_GOAL := publish

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

gpg:
	GPG_TTY=$(tty)
	export GPG_TTY

commit: gpg
	git add --all .
	git commit -s -m "$(COMMIT_MESSAGE)"
	git push

tag:
	if git tag -l --sort=v:refname | grep -q "$(TAG)" ; then git tag -d "$(TAG)" ; git push --delete origin "$(TAG)" ; fi
	git tag -a -m "$(TAG)" "$(TAG)"
	git push origin "$(TAG)"

publish: check commit tag

setup: gpg
	gpgconf --kill gpg-agent
	rm -rf ~/.gnupg
	gpg-agent --homedir "${GNUPGHOME:-$HOME/.gnupg}" --daemon
	gpg --import "$(GPG_KEY)"
	git config --global user.signingKey $(gpg --list-secret-keys --keyid-format long | awk -F/ '/^sec/ {print $2}' | awk '{print $1}')
	git config --global commit.gpgSign true

remove-tags:
	git tag --list | xargs git push --delete origin
	git tag --list | xargs git tag -d