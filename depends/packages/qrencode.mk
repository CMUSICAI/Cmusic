package=qrencode
$(package)_version=4.1.1
$(package)_download_path=https://codeload.github.com/fukuchi/libqrencode/tar.gz/v$($(package)_version)
$(package)_file_name=libqrencode-$($(package)_version).tar.gz
$(package)_sha256_hash=5385bc1b8c2f20f3b91d258bf8ccc8cf62023935df2d2676b5b67049f31a049c

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --without-tools
  $(package)_config_opts_linux=--with-pic
  $(package)_autoreconf = YES
endef

define $(package)_config_cmds
  autoconf
  ./configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  make
endef

define $(package)_stage_cmds
  make DESTDIR=$($(package)_staging_dir) install
endef
