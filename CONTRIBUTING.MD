## Test and Lint

### Installation

```sh
$ brew install chart-testing yamllint
$ helm plugin install https://github.com/quintush/helm-unittest
```

### Execution

```sh
# unit testing
helm unittest ./charts/{chart-name}

# linting
$ ct lint --target-branch main
```