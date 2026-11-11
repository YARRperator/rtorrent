variable "IMAGE" {
  default = "ghcr.io/yarrperator/rtorrent"
}

variable "alpine_version" {
  default = "3.24"
}

variable "rtorrent_version" {
  default = ""
}

variable "sha" {
  default = ""
}

target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    ALPINE_VERSION = "${alpine_version}"
  }
  tags = [
    "${IMAGE}:latest",
    "${IMAGE}:alpine${alpine_version}-rtorrent${rtorrent_version}",
    "${IMAGE}:sha-${sha}"
  ]
  output = ["type=registry"]
}
