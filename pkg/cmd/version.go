package version

import (
	"encoding/json"
	"fmt"

	"github.com/aneeshkp/cobra-operator/pkg/version"
	"github.com/spf13/cobra"
)

// NewVersionCommand creates the command that exposes the version
func NewVersionCommand() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the version",
		Long:  `Print the version and build information`,
		RunE: func(cmd *cobra.Command, args []string) error {
			info := version.Get()
			json, err := json.Marshal(info)
			if err != nil {
				return err
			}
			fmt.Println(string(json))

			return nil
		},
	}
}
