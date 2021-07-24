package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	log "github.com/sirupsen/logrus"
)

var (
	Token  string
	ChatId string
)

func getEnvVariable(env string) (string, error) {
	recomandation := fmt.Sprintf("Run the following command: 'export %s=\"<%s>\"'", env, env)
	envContent, ok := os.LookupEnv(env)
	if !ok {

		return "", fmt.Errorf("%s doesn't exists. %s", env, recomandation)
	}
	if len(strings.TrimSpace(envContent)) == 0 {
		return "", fmt.Errorf("%s is empty. %s", env, recomandation)
	}
	return envContent, nil
}

func getUrl() string {
	return fmt.Sprintf("https://api.telegram.org/bot%s", Token)
}

func SendMessage(text string) (bool, error) {
	// Global variables
	var err error
	var response *http.Response

	// Send the message
	url := fmt.Sprintf("%s/sendMessage", getUrl())
	body, _ := json.Marshal(map[string]string{
		"chat_id": ChatId,
		"text":    text,
	})
	response, err = http.Post(
		url,
		"application/json",
		bytes.NewBuffer(body),
	)
	if err != nil {
		return false, err
	}

	// Close the request at the end
	defer response.Body.Close()

	// Body
	body, err = ioutil.ReadAll(response.Body)
	if err != nil {
		return false, err
	}

	// Log
	log.Infof("Message '%s' was sent", text)
	log.Infof("Response JSON: %s", string(body))

	// Return
	return true, nil
}

func main() {
	// Get the TOKEN and the CHAT_ID
	var err error
	Token, err = getEnvVariable("TOKEN")
	if err != nil {
		log.Fatalf("%s", err)
	}
	ChatId, err = getEnvVariable("CHAT_ID")
	if err != nil {
		log.Fatalf("%s", err)
	}

	// Add a flag
	var message string
	flag.StringVar(&message, "message", "Hello There!", "Message that will be send")
	flag.Parse()

	// Send a message
	_, err = SendMessage(message)
	if err != nil {
		log.Fatalf("%s", err)
	}
}
