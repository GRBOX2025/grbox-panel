package main

import (
    "log"
    "net/http"
)

func main() {
    fs := http.FileServer(http.Dir("./web/html"))
    http.Handle("/", fs)
    log.Println("GRBOX Panel работает на порту :2053")
    err := http.ListenAndServe(":2053", nil)
    if err != nil {
        log.Fatal(err)
    }
}
