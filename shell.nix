{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fd3e33d696b81e76b30160dfad2efb7ac1f19879.tar.gz") {}
}:
with rec { 
  # TODO match the exact version of boring from the chrome build
  boring-version = "f1c75347daa2ea81a941e953f2263e0a4d970c8d";
  boring-source = builtins.fetchTarball {
    url = "https://github.com/google/boringssl/archive/${boring-version}.tar.gz";
    sha256 = "092bpnzqrwc5blyra2h8483i0l0r0hwkhb4qhvsnp4lldpwp0c57";
  };
};
pkgs.mkShell {
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.which
    pkgs.rustup
    pkgs.libiconv
    pkgs.git
    pkgs.openssh
    pkgs.openssl.dev
    boring-source
    pkgs.pkg-config
    pkgs.cacert
    pkgs.zlib
    # prost proto build
    pkgs.gcc
    pkgs.cmake
    pkgs.protobuf
    # pkgs.go
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.SystemConfiguration ] ;
  PROTOC = "${pkgs.protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${pkgs.protobuf}/include";
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib";
  RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
  RUST_BACKTRACE=1;
  BORING_BSSL_SOURCE_PATH="${boring-source}";
  CARGO_HOME="";
  BINDGEN_EXTRA_CLANG_ARGS=
    ''${pkgs.lib.readFile "${pkgs.stdenv.cc}/nix-support/libc-crt1-cflags"} '' +
    ''${pkgs.lib.readFile "${pkgs.stdenv.cc}/nix-support/libc-cflags"} '' + 
    ''${pkgs.lib.readFile "${pkgs.stdenv.cc}/nix-support/cc-cflags"}  '' +
    ''${pkgs.lib.readFile "${pkgs.stdenv.cc}/nix-support/libcxx-cxxflags"} '' + 
    ''${pkgs.lib.optionalString pkgs.stdenv.cc.isClang "-idirafter ${pkgs.stdenv.cc.cc}/lib/clang/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/include"} '' +
    ''${pkgs.lib.optionalString pkgs.stdenv.cc.isGNU "-isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.lib.getVersion pkgs.stdenv.cc.cc} -isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/${pkgs.stdenv.hostPlatform.config} -idirafter ${pkgs.stdenv.cc.cc}/lib/gcc/${pkgs.stdenv.hostPlatform.config}/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/include"}''
    ;
}