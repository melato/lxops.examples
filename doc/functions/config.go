package functions

import (
	"fmt"
	"sort"

	"melato.org/lxops/cfg"
)

type ConfigMethods struct {
}

func (t *ConfigMethods) ReadRaw(filename string) (*cfg.Config, error) {
	return cfg.ReadConfigYaml(filename)
}

func (t *ConfigMethods) Read(filename string, properties map[string]any) (*cfg.Config, error) {
	get := func(name string) (string, bool) {
		value, found := properties[name]
		fmt.Printf("get(%s): %v(%T)\n", name, value, value)
		if !found {
			return "", false
		}
		s, isString := value.(string)
		if !isString {
			return "", false
		}
		return s, true
	}
	return cfg.ReadConfig(filename, get)
}

func (t *ConfigMethods) FilesystemNames(c *cfg.Config) []string {
	if len(c.Filesystems) == 0 {
		return nil
	}
	names := make([]string, 0, len(c.Filesystems))
	for name, _ := range c.Filesystems {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}
