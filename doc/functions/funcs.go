package functions

import (
	_ "embed"
)

//go:embed funcs.txt
var funcUsage []byte

type Funcs interface {
	SetFunc(string, any)
	AddUsageTxt([]byte)
}

func AddFuncs(funcs Funcs) {
	funcs.SetFunc("yaml", PrintYaml)
	funcs.SetFunc("strings", func() *Strings { return &Strings{} })
	funcs.SetFunc("File", func() *File { return &File{} })
	funcs.SetFunc("Config", func() *ConfigMethods { return &ConfigMethods{} })
	funcs.AddUsageTxt(funcUsage)
}
