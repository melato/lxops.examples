package functions

import (
	"path/filepath"
)

type File struct {
}

func (t *File) Dir(path string) string {
	return filepath.Dir(path)
}
