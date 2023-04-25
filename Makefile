# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## charttesting: Run Helm chart unit tests
.PHONY: charttesting
charttesting:
	for dir in charts/steadybit-*; do \
    echo "Unit Testing $$dir"; \
    helm unittest $$dir; \
  done

## chartlint: Lint charts
.PHONY: chartlint
chartlint:
	ct lint --config chartTesting.yaml
