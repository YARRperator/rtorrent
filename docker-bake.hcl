variable "IMAGE" {
  default = "ghcr.io/yarrperator/rtorrent"
}

variable "alpine_version" {
  default = "3.24"
}

variable "rtorrent_version" {
  default = ""
}

target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    ALPINE_VERSION = "${alpine_version}"
  }
  tags = [
    "${IMAGE}:latest",
    "${IMAGE}:alpine${alpine_version}-${rtorrent_version}"
  ]
  output = ["type=registry"]
}
