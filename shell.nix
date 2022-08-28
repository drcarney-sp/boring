{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fd3e33d696b81e76b30160dfad2efb7ac1f19879.tar.gz") {}
}:
pkgs.mkShell {
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.which
    pkgs.rustup
    pkgs.libiconv
    pkgs.git
    pkgs.openssh
    pkgs.openssl.dev
    pkgs.pkg-config
    pkgs.cacert
    pkgs.zlib
    # prost proto build
    pkgs.gcc
    pkgs.cmake
    pkgs.protobuf
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.SystemConfiguration ] ;
  PROTOC = "${pkgs.protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${pkgs.protobuf}/include";
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib";
  RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
  RUST_BACKTRACE=1;
  CARGO_HOME="";
  shellHook = ''
    export BINDGEN_EXTRA_CLANG_ARGS="$(< ${pkgs.stdenv.cc}/nix-support/libc-crt1-cflags) \
      $(< ${pkgs.stdenv.cc}/nix-support/libc-cflags) \
      $(< ${pkgs.stdenv.cc}/nix-support/cc-cflags) \
      $(< ${pkgs.stdenv.cc}/nix-support/libcxx-cxxflags) \
      ${pkgs.lib.optionalString pkgs.stdenv.cc.isClang "-idirafter ${pkgs.stdenv.cc.cc}/lib/clang/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/include"} \
      ${pkgs.lib.optionalString pkgs.stdenv.cc.isGNU "-isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.lib.getVersion pkgs.stdenv.cc.cc} -isystem ${pkgs.stdenv.cc.cc}/include/c++/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/${pkgs.stdenv.hostPlatform.config} -idirafter ${pkgs.stdenv.cc.cc}/lib/gcc/${pkgs.stdenv.hostPlatform.config}/${pkgs.lib.getVersion pkgs.stdenv.cc.cc}/include"} \
    "
  '';
}