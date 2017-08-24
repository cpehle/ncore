new_http_archive(
    name = "gtest",
    url = "https://github.com/google/googletest/archive/release-1.7.0.zip",
    sha256 = "b58cb7547a28b2c718d1e38aee18a3659c9e3ff52440297e965f5edffe34b6d0",
    build_file = "gtest.BUILD",
    strip_prefix = "googletest-release-1.7.0",
)

new_http_archive(
    name = "pybind11",
    url = "https://github.com/pybind/pybind11/archive/master.zip",
    sha256 = "",
    build_file = "pybind11.BUILD",
    strip_prefix = "pybind11-master",
)

git_repository(
    name = "verilator",
    remote = "https://github.com/cpehle/verilator",
    commit = "eb5434b85e8dd3870f959c2b07bb230364ccf920",
)
