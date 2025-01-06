# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## charttesting: Run Helm chart unit tests
.PHONY: charttesting
charttesting:
	@set -e; \
	for dir in charts/steadybit-*; do \
		echo "Unit Testing $$dir"; \
		helm unittest $$dir; \
	done

## chartlint: Lint charts
.PHONY: chartlint
chartlint:
	ct lint --config chartTesting.yaml

## chart-bump-version: Set the appVersion
.PHONY: chart-set-app-version
chart-set-app-version:
	@set -e; \
	if [ -z "$(CHART)" ]; then\
		echo "no chart specified"; \
		exit 1; \
	fi; \
	if [ ! -z "$(APP_VERSION)" ]; then \
		yq -i ".appVersion = strenv(APP_VERSION)" charts/$(CHART)/Chart.yaml; \
	fi; \
	grep -e "^appVersion:" charts/$(CHART)/Chart.yaml;


## chart-bump-version: Bump the patch version
.PHONY: chart-bump-version
chart-bump-version:
	@set -e; \
	if [ -z "$(CHART)" ]; then\
		echo "no chart specified"; \
		exit 1; \
	fi; \
	CHART_VERSION=$$(semver -i patch $$(yq '.version' charts/$(CHART)/Chart.yaml)) \
	yq -i ".version = strenv(CHART_VERSION)" charts/$(CHART)/Chart.yaml; \
	grep -e "^version:" charts/$(CHART)/Chart.yaml;
