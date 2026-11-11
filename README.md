# rtorrent

rtorrent, in a container.

Alpine-based image with rtorrent from the Alpine community repository. Multi-arch (amd64 + arm64) via docker buildx bake.

## Image

```
ghcr.io/yarrperator/rtorrent:latest
```

Runs as UID:GID 1000:1000. No home directory.

### Tags

| Tag | Description |
|-----|-------------|
| `:latest` | Latest build from main |
| `:alpine<alpine>-rtorrent<version>` | Pinned to specific Alpine + rtorrent package versions |

Example: `ghcr.io/yarrperator/rtorrent:alpine3.24-rtorrent0.16.12-r0`

## Usage

### Docker

```bash
docker run -d \
  -v ./rtorrent.rc:/etc/rtorrent/rtorrent.rc:ro \
  -v ./data:/data \
  -v ./downloads:/downloads \
  -p 9510:9510 \
  ghcr.io/yarrperator/rtorrent:latest
```

The default CMD loads `/etc/rtorrent/rtorrent.rc`. Override args to customize:

```bash
docker run ghcr.io/yarrperator/rtorrent:latest -n -o "import=/custom/config.rc"
```

### Kubernetes

A starter deployment template is in `deploy/k8s/`. It includes:

- **rtorrent** deployment with init containers (dir setup, stale lock cleanup), SCGI socket probes, graceful shutdown, and a ConfigMap for `rtorrent.rc`
- **flood** deployment (web UI via [jesec/flood](https://github.com/jesec/flood)) sharing the same PVCs to access rtorrent's SCGI socket
- PVCs for application data and downloads
- Services for both rtorrent (BT port) and flood (HTTP)

```bash
kubectl apply -k deploy/k8s/
```

#### Notes

- Adjust storage class names, PVC sizes, services, and the `rtorrent.rc` ConfigMap to suit your environment. \
- Bring your own auth for flood or enable the native auth it has. \
- Bring your own tcp/udp ingress for rtorrent (we like Cilium LoadBalancers).

## Kubernetes Probes

The image includes `test` (busybox builtin). Use it to check the rtorrent SCGI socket for liveness/readiness:

```yaml
startupProbe:
  exec:
    command:
    - test
    - -S
    - /data/socket/rtorrent.socket
  periodSeconds: 10
  failureThreshold: 2147483646  # effectively unlimited — rtorrent can take a while to load session

livenessProbe:
  exec:
    command:
    - test
    - -S
    - /data/socket/rtorrent.socket
  periodSeconds: 30
  failureThreshold: 3

readinessProbe:
  exec:
    command:
    - test
    - -S
    - /data/socket/rtorrent.socket
  periodSeconds: 10
  failureThreshold: 3
```

Socket path is configured by the user in `rtorrent.rc` via `network.scgi.open_local`. The probe just checks the file exists.

## Building

GitHub Actions workflow at `.github/workflows/build.yml` builds and pushes the image to GHCR. Triggered manually via `workflow_dispatch`.

The workflow:
1. Detects the rtorrent package version from the Alpine repo
2. Builds multi-arch images (amd64 + arm64) via `docker/bake-action`
3. Pushes two tag variants (latest, version-pinned)

Build configuration is in `docker-bake.hcl`. The Alpine version is a build arg that can be overridden:

```bash
docker buildx bake --set default.alpine_version=3.23
```

## License

AGPL-3.0
