SHELL=/bin/bash
GO111MODULE=on
BINARY_NAME=main.bin

export GO111MODULE

.DEFAULT_GOAL := build

prerequisites:
	go fmt
	go get
	go mod tidy

lint:
	golangci-lint run

clean:
	go clean
	rm -f "$(BINARY_NAME)" __debug_bin

build: prerequisites lint
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME) main.go

run: build
	bash -c '. .env && export TOKEN CHAT_ID && ./$(BINARY_NAME)'