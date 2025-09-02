package main

import (
	"fmt"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"
)

var reqCounter = prometheus.NewCounter(
	prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "No of request handled",
	},
)

func main() {

	prometheus.MustRegister(reqCounter)

	router := http.NewServeMux()

	router.Handle("/metrics", promhttp.Handler())

	router.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		reqCounter.Inc()
		podName := os.Getenv("HOSTNAME")
		if podName == "" {
			podName = "Неизвестен"
		}

		// Увеличение потребления памяти.
		// Кажется без случайного числа go хорошо оптимизирует код и память практически не используется
		random := rand.New(rand.NewSource(time.Now().UnixNano()))
		n := random.Intn(901) + 100

		var stringsSlice []string
		for i := 0; i < n; i++ {
			s := "строка номер " + string(i)
			stringsSlice = append(stringsSlice, s)
		}

		log.Println("Идентификатор пода: %s\n", podName)
		fmt.Fprintf(w, "Идентификатор пода: %s\n", podName)
	})

	http.ListenAndServe(":8080", router)

}
