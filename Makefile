VERSION_DATE ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
BIN_DIR ?= "build/_output/bin"
OPERATOR_NAME ?= cobra-operator
OUTPUT_BINARY ?= "$(BIN_DIR)/$(OPERATOR_NAME)"
GO_FLAGS ?= GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=on
VERSION_PKG ?= "github.com/aneeshkp/cobra-operator/pkg/version"
COBRA_VERSION=?= "$(shell grep -v '\#'cobra.version)"
KUBERNETES_CONFIG ?= "$(HOME)/.kube/config"
LD_FLAGS ?= "-X $(VERSION_PKG).version=$(OPERATOR_VERSION) -X $(VERSION_PKG).buildDate=$(VERSION_DATE) -X $(VERSION_PKG).defaultJaeger=$(COBRA_VERSION)"
SDK_VERSION=v0.8.1



.DEFAULT_GOAL := build

.PHONY: vendor
vendor:
	@echo Building vendor...
	@${GO_FLAGS} go mod vendor

.PHONY: check
check: vendor
	@echo Checking...
	@go fmt $(PACKAGES) > $(FMT_LOG)
	@.travis/import-order-cleanup.sh stdout > $(IMPORT_LOG)
	@[ ! -s "$(FMT_LOG)" -a ! -s "$(IMPORT_LOG)" ] || (echo "Go fmt, license check, or import ordering failures, run 'make format'" | cat - $(FMT_LOG) $(IMPORT_LOG) && false)

.PHONY: format
format: vendor
	@echo Formatting code...
	@go fmt $(PACKAGES)

.PHONY: lint
lint:
	@echo Linting...
	@golint -set_exit_status=1 $(PACKAGES)

.PHONY: build
build: vendor format
	@echo Building...
	@${GO_FLAGS} go build -o $(OUTPUT_BINARY) -ldflags $(LD_FLAGS)


.PHONY: install-sdk
install-sdk:
	@echo Installing SDK ${SDK_VERSION}
	@curl https://github.com/operator-framework/operator-sdk/releases/download/${SDK_VERSION}/operator-sdk-${SDK_VERSION}-x86_64-linux-gnu -sLo ${GOPATH}/bin/operator-sdk
	@chmod +x ${GOPATH}/bin/operator-sdk

.PHONY: install-tools
install-tools:
	@go get -u golang.org/x/lint/golint
	@go get github.com/securego/gosec/cmd/gosec/...