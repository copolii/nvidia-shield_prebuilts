#
# Copyright (c) 2013 NVIDIA Corporation.  All rights reserved.
#

ifneq ($(TARGET_SIMULATOR),true)
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

nvflash_cfg_names := np nb gp gb
ifeq ($(NV_TN_SKU),tn7_114gp)
nvflash_cfg_default := gp
endif
ifeq ($(NV_TN_SKU),tn7_114gb)
nvflash_cfg_default := gb
endif
ifeq ($(NV_TN_SKU),tn7_114np)
nvflash_cfg_default := np
endif
ifeq ($(NV_TN_SKU),tn7_114nb)
nvflash_cfg_default := nb
endif
ifeq ($(NV_TN_SKU),kalamata)
nvflash_cfg_default := gp
endif
nvflash_cfg_default_target := $(PRODUCT_OUT)/flash.cfg

ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data),)
sedoptionnp := -e "s/name=LBH/name=LBH\nfilename=lbh_np.img/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_np.txt/"

sedoptionnb := -e "s/name=LBH/name=LBH\nfilename=lbh_nb.img/" \
	-e "s/tegra114-tegratab.dtb/tegra114-tegratab-b.dtb/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_nb.txt/"

sedoptiongp := -e "s/name=LBH/name=LBH\nfilename=lbh_gp.img/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_gp.txt/"

sedoptiongb := -e "s/name=LBH/name=LBH\nfilename=lbh_gb.img/" \
	-e "s/tegra114-tegratab.dtb/tegra114-tegratab-b.dtb/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_gp.txt/"
else
sedoptionnp := -e "s/name=LBH/name=LBH\nfilename=lbh_np.img/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_np.txt/" \
	-e "s/factory_ramdisk.img/boot.img/"

sedoptionnb := -e "s/name=LBH/name=LBH\nfilename=lbh_nb.img/" \
	-e "s/tegra114-tegratab.dtb/tegra114-tegratab-b.dtb/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_nb.txt/" \
	-e "s/factory_ramdisk.img/boot.img/"

sedoptiongp := -e "s/name=LBH/name=LBH\nfilename=lbh_gp.img/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_gp.txt/" \
	-e "s/factory_ramdisk.img/boot.img/"

sedoptiongb := -e "s/name=LBH/name=LBH\nfilename=lbh_gb.img/" \
	-e "s/tegra114-tegratab.dtb/tegra114-tegratab-b.dtb/" \
	-e "s/name=NCT/name=NCT\n\#filename=nct_gp.txt/" \
	-e "s/factory_ramdisk.img/boot.img/"
endif

define nvflash-cfg-populate-lbh
$(foreach _lbh,$(nvflash_cfg_names), \
  $(eval _target := $(PRODUCT_OUT)/flash_$(_lbh).cfg) \
  $(eval _out2 := $(if $(call streq,$(_lbh),$(nvflash_cfg_default)),| tee $(nvflash_cfg_default_target),)) \
  mkdir -p $(dir $(_target)); \
  sed $(sedoption$(_lbh)) < $(NVFLASH_CFG_BASE_FILE) $(_out2) > $(_target); \
)
endef

LOCAL_MODULE := nvflash_cfg_populator
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_SUFFIX := -timestamp
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(NVFLASH_CFG_BASE_FILE)
	$(hide) $(call nvflash-cfg-populate-lbh)

endif # !TARGET_SIMULATOR
