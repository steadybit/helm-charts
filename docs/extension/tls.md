# Extension TLS Support

All official Steadybit extensions have support for TLS connections. When correctly configured, they will start an HTTPS server instead of an HTTP server. Furthermore, you can instruct extensions to validate client certificates to implement mutual TLS. This document describes configuring the Helm charts to realize this (the instructions apply to all extension Helm charts).

## On Certificates

You need to have a TLS certificate and key for the extension. The certificates need to be maintained as [Kubernetes TLS secrets](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) or as opaque Kubernetes secrets complying with the Kubernetes TLS secret specification.

You may use separate TLS certificates for the client and server. They do not have to be signed by the same certificate authority.

## Starting Extension HTTPS Servers

To start an extension in HTTPS mode, you must populate the `tls.server.certificate.fromSecret` Helm chart value. The value must be the name [of a secret containing the certificate](#on-certificates). Once done, the extension will only accept HTTPS connections.

You must ensure that Steadybit agents trust the configured certificate's authority. You can learn how this can be achieved within the [Steadybit agent's Helm chart documentation](../../charts/steadybit-agent/README.md#importing-your-own-certificates).

## Enabling Mutual TLS

To have agents authenticate when communicating with extensions, you can leverage Mutual TLS. To achieve this, you need to

 - Populate the `tls.client.certificates.fromSecrets` (`string[]`) Helm chart value with the names of secrets containing the [client certificates](#on-certificates).
 - Make sure that the Steadybit agent has access to [the certificates](#on-certificates) by setting the `agent.extensions.mutualTls.certificates.fromSecrets` (`string[]`) Helm chart value. This will mount the certificates as files in the agent's container.
 - Ensure that the agent uses these certificates when communicating with the extensions. For auto-discovered extensions, this is done automatically.

