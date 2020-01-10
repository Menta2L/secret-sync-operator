package version

import (
	"fmt"
	"runtime"

	sdkVersion "github.com/operator-framework/operator-sdk/version"
)

var (
	Version = "0.0.1"
)

var (
	// RELEASE returns the release version
	RELEASE = "UNKNOWN"
	// REPO returns the git repository URL
	REPO = "UNKNOWN"
	// COMMIT returns the short sha from git
	COMMIT = "UNKNOWN"
)

// String returns information about the release.
func String() string {
	return fmt.Sprintf(`-------------------------------------------------------------------------------
Secret Sync Controller
  Release:       %v
  Build:         %v
  Repository:    %v
  Version:       %v
  Go Version:    %v
  OS/Arch:       %v/%v
  Operator SDK   %v
-------------------------------------------------------------------------------
`, RELEASE, COMMIT, REPO, Version, runtime.Version(), runtime.GOOS, runtime.GOARCH, sdkVersion.Version)
}
