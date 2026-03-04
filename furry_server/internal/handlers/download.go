package handlers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

type DownloadHandler struct {
	APKPath      string
	DownloadName string
	APKVersion   string
}

func (h *DownloadHandler) buildDownloadName(baseName string, fileInfo os.FileInfo) string {
	nameWithoutExt := strings.TrimSuffix(baseName, filepath.Ext(baseName))
	if nameWithoutExt == "" {
		nameWithoutExt = "maohaizi-riji"
	}

	version := strings.TrimSpace(h.APKVersion)
	version = strings.ReplaceAll(version, " ", "-")
	version = strings.ReplaceAll(version, "/", "-")
	version = strings.Trim(version, "-_")

	buildDate := fileInfo.ModTime().UTC().Format("20060102")
	if version != "" && version != "unknown" {
		if !strings.HasPrefix(strings.ToLower(version), "v") {
			version = "v" + version
		}
		return fmt.Sprintf("%s-%s-%s.apk", nameWithoutExt, version, buildDate)
	}

	return fmt.Sprintf("%s-%s.apk", nameWithoutExt, buildDate)
}

func (h *DownloadHandler) resolveAPK() (string, string, os.FileInfo, error) {
	if h.APKPath == "" {
		return "", "", nil, fmt.Errorf("apk path is not configured")
	}

	fileInfo, err := os.Stat(h.APKPath)
	if err != nil {
		return "", "", nil, err
	}

	downloadName := h.DownloadName
	if downloadName == "" {
		downloadName = filepath.Base(h.APKPath)
	}
	downloadName = h.buildDownloadName(downloadName, fileInfo)

	return h.APKPath, downloadName, fileInfo, nil
}

func (h *DownloadHandler) DownloadAPK(c *gin.Context) {
	apkPath, downloadName, _, err := h.resolveAPK()
	if err != nil {
		if err.Error() == "apk path is not configured" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if os.IsNotExist(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "apk file not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Header("Content-Type", "application/vnd.android.package-archive")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", downloadName))
	c.Header("X-Content-Type-Options", "nosniff")
	c.File(apkPath)
}

func (h *DownloadHandler) LatestAPKMeta(c *gin.Context) {
	apkPath, downloadName, fileInfo, err := h.resolveAPK()
	if err != nil {
		if err.Error() == "apk path is not configured" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if os.IsNotExist(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "apk file not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	version := h.APKVersion
	if version == "" {
		version = "unknown"
	}

	basePath := c.Request.URL.Path
	if strings.HasSuffix(basePath, "/meta") {
		basePath = strings.TrimSuffix(basePath, "/meta")
	}

	scheme := "http"
	if c.Request.TLS != nil {
		scheme = "https"
	}
	downloadURL := fmt.Sprintf("%s://%s%s", scheme, c.Request.Host, basePath)

	c.JSON(http.StatusOK, gin.H{
		"version":     version,
		"fileName":    downloadName,
		"sizeBytes":   fileInfo.Size(),
		"updatedAt":   fileInfo.ModTime().UTC().Format("2006-01-02T15:04:05Z"),
		"mimeType":    "application/vnd.android.package-archive",
		"downloadUrl": downloadURL,
	})
}
