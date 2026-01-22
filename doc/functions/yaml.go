package functions

import (
	"gopkg.in/yaml.v2"
)

func PrintYaml(v any) (string, error) {
	data, err := yaml.Marshal(v)
	if err != nil {
		return "", err
	}
	return string(data), nil
}
