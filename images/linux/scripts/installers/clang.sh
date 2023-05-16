#!/bin/bash -e
################################################################################
##  File:  clang.sh
##  Desc:  Installs Clang compiler
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

function InstallClang {
    local version=$1
    local package_version=$2

    echo "Installing clang-$version..."
    apt-get install -y "clang-$version=$package_version" "lldb-$version=$package_version" "lld-$version=$package_version" "clang-format-$version=$package_version" "clang-tidy-$version=$package_version"
}

function SetDefaultClang {
    local version=$1

    echo "Make Clang ${version} default"
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${version} 100
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${version} 100
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${version} 100
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${version} 100
    update-alternatives --install /usr/bin/run-clang-tidy run-clang-tidy /usr/bin/run-clang-tidy-${version} 100
}

versions=$(get_toolset_value '.clang.versions[]')
default_clang_version=$(get_toolset_value '.clang.default_version')

for version in ${versions[*]}; do
    package_version=$(get_toolset_value '.clang.packageVersions.'$version)
    if [[ $version != $default_clang_version ]]; then
        InstallClang $version $package_version
    fi
done

package_version=$(get_toolset_value '.clang.packageVersions.'$default_clang_version)
InstallClang $default_clang_version $package_version
SetDefaultClang $default_clang_version

invoke_tests "Tools" "clang"
