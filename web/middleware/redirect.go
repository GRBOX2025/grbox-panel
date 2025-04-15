package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func RedirectMiddleware(basePath string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Redirect from old '/grbox' path to '/panel'
		redirects := map[string]string{
			"panel/API": "panel/api",
			"grbox/API":   "panel/api",
			"grbox":       "panel",
		}

		path := c.Request.URL.Path
		for from, to := range redirects {
			from, to = basePath+from, basePath+to

			if strings.HasPrefix(path, from) {
				newPath := to + path[len(from):]

				c.Redirect(http.StatusMovedPermanently, newPath)
				c.Abort()
				return
			}
		}

		c.Next()
	}
}
