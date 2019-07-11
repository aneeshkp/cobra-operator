package version

import (
	"fmt"
	"runtime"

	sdkVersion "github.com/operator-framework/operator-sdk/version"
	"github.com/spf13/viper"
)

var (
	version      string
	buildDate    string
	defaultCobra string
)

// Version holds this Operator's version as well as the version of some of the components it uses
type Version struct {
	Operator    string `json:"cobra-operator"`
	BuildDate   string `json:"build-date"`
	Cobra       string `json:"cobra-version"`
	Go          string `json:"go-version"`
	OperatorSdk string `json:"operator-sdk-version"`
}

// Get returns the Version object with the relevant information
func Get() Version {
	var cobra string
	if viper.IsSet("cobra-version") {
		cobra = viper.GetString("cobra-version")
	} else {
		cobra = defaultCobra
	}

	return Version{
		Operator:    version,
		BuildDate:   buildDate,
		Cobra:       cobra,
		Go:          runtime.Version(),
		OperatorSdk: sdkVersion.Version,
	}
}

func (v Version) String() string {
	return fmt.Sprintf(
		"Version(Operator='%v', BuildDate='%v', Cobra='%v', Go='%v', OperatorSDK='%v')",
		v.Operator,
		v.BuildDate,
		v.Cobra,
		v.Go,
		v.OperatorSdk,
	)
}

// DefaultCobra returns the default Cobra to use when no versions are specified via CLI or configuration
func DefaultCobra() string {
	return defaultCobra
}
