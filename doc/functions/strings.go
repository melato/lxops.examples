package functions

import (
	"strings"
)

type Strings struct {
}

func (t *Strings) Join(args []string, sep string) string {
	return strings.Join(args, sep)
}
