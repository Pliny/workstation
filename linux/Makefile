######## Shell Commands

INSTALL_PROGRAM      := install -m 755 -p
INSTALL_CONFIG       := install -m 644 -p
CHK_DIR_EXISTS       := test -d
MKDIR                := mkdir -p
DEL_FILE             := rm -f
RELOAD_UDEV          := udevadm control --reload
SYSTEMCTL_PROGRAM    := systemctl


######## Files to Install

BACKUP_SH            := backup.sh
BACKUP_CONFIG        := backup
BACKUP_LOGROTATE     := backup
USBDISKMOUNT_SH      := usbdiskmount.sh
USBDISKMOUNT_CONFIG  := usbdiskmount
USBDISKMOUNT_SYSTEMD := usbdiskmount@.service
USBDISKMOUNT_UDEV    := usbdiskmount.rules
USBDISKMOUNT_LOGROTATE := usbdiskmount
PHP_CGI_SYSTEMD      := php-cgi.service
XORG_SYSTEMD         := xorg.service
MYTHBACKEND_SYSTEMD  := mythbackend.service
MYTHFRONTEND_SYSTEMD := mythfrontend.service
MYTHTV_LOGROTATE     := mythtv
XORGLOGIN_SH         := xorglogin.sh


######## Paths

SBIN_PATH            := $(INSTALL_ROOT)/usr/local/sbin/
BIN_PATH             := $(INSTALL_ROOT)/usr/local/bin/
CONFIG_PATH          := $(INSTALL_ROOT)/etc/config/
SYSTEMD_PATH         := $(INSTALL_ROOT)/usr/local/lib/systemd/system
UDEV_PATH            := $(INSTALL_ROOT)/etc/udev/rules.d/
LOGROTATE_PATH       := $(INSTALL_ROOT)/etc/logrotate.d/
MYTHTV_LOG_PATH      := $(INSTALL_ROOT)/var/log/mythtv/

####### USBDISKMOUNT
USBDISKMOUNT_AUDIO_PATH := $(INSTALL_ROOT)/usr/local/share/usbdiskmount
INSERT_SND              := usbdisk_insert.wav
REMOVE_SND              := usbdisk_remove.wav
FAIL_SND                := usbdisk_fail.wav



install:     install_backup   install_usbdiskmount   install_php_cgi   install_xorg   install_mythtv

uninstall: uninstall_backup uninstall_usbdiskmount uninstall_php_cgi uninstall_xorg uninstall_mythtv


install_backup:
	@$(CHK_DIR_EXISTS) $(SBIN_PATH)      || $(MKDIR) $(SBIN_PATH)
	@$(CHK_DIR_EXISTS) $(CONFIG_PATH)    || $(MKDIR) $(CONFIG_PATH)
	@$(CHK_DIR_EXISTS) $(LOGROTATE_PATH) || $(MKDIR) $(LOGROTATE_PATH)
	$(INSTALL_PROGRAM) "$(BACKUP_SH)"     $(SBIN_PATH)
	$(INSTALL_CONFIG) "config/$(BACKUP_CONFIG)" $(CONFIG_PATH)
	$(INSTALL_CONFIG) "logrotate/$(BACKUP_LOGROTATE)" $(LOGROTATE_PATH)

install_usbdiskmount:
	@$(CHK_DIR_EXISTS) $(BIN_PATH)     || $(MKDIR) $(BIN_PATH)
	@$(CHK_DIR_EXISTS) $(CONFIG_PATH)  || $(MKDIR) $(CONFIG_PATH)
	@$(CHK_DIR_EXISTS) $(SYSTEMD_PATH) || $(MKDIR) $(SYSTEMD_PATH)
	@$(CHK_DIR_EXISTS) $(UDEV_PATH)    || $(MKDIR) $(UDEV_PATH)
	@$(CHK_DIR_EXISTS) $(LOGROTATE_PATH) || $(MKDIR) $(LOGROTATE_PATH)
	@$(CHK_DIR_EXISTS) $(USBDISKMOUNT_AUDIO_PATH) || $(MKDIR) $(USBDISKMOUNT_AUDIO_PATH)
	$(INSTALL_PROGRAM) "$(USBDISKMOUNT_SH)"      $(BIN_PATH)
	$(INSTALL_CONFIG) "config/$(USBDISKMOUNT_CONFIG)"  $(CONFIG_PATH)
	$(INSTALL_CONFIG) "logrotate/$(USBDISKMOUNT_LOGROTATE)" $(LOGROTATE_PATH)
	$(INSTALL_CONFIG) "udev/rules.d/$(USBDISKMOUNT_UDEV)"    $(UDEV_PATH)
	$(INSTALL_CONFIG) "systemd/system/$(USBDISKMOUNT_SYSTEMD)" $(SYSTEMD_PATH)
	$(INSTALL_CONFIG) "share/usbdiskmount/$(INSERT_SND)" $(USBDISKMOUNT_AUDIO_PATH)
	$(INSTALL_CONFIG) "share/usbdiskmount/$(FAIL_SND)"   $(USBDISKMOUNT_AUDIO_PATH)
	$(INSTALL_CONFIG) "share/usbdiskmount/$(REMOVE_SND)" $(USBDISKMOUNT_AUDIO_PATH)
	@echo "Reloading udev..."
	$(RELOAD_UDEV)

install_php_cgi:
	@$(CHK_DIR_EXISTS) $(SYSTEMD_PATH) || $(MKDIR) $(SYSTEMD_PATH)
	$(INSTALL_CONFIG) "systemd/system/$(PHP_CGI_SYSTEMD)" $(SYSTEMD_PATH)
	@echo "Starting $(PHP_CGI_SYSTEMD).."
	$(SYSTEMCTL_PROGRAM) enable $(PHP_CGI_SYSTEMD)
	$(SYSTEMCTL_PROGRAM) start $(PHP_CGI_SYSTEMD)

install_xorg:
	@$(CHK_DIR_EXISTS) $(SBIN_PATH)    || $(MKDIR) $(SBIN_PATH)
	@$(CHK_DIR_EXISTS) $(SYSTEMD_PATH) || $(MKDIR) $(SYSTEMD_PATH)
	$(INSTALL_PROGRAM) $(XORGLOGIN_SH) $(SBIN_PATH)
	$(INSTALL_CONFIG) "systemd/system/$(XORG_SYSTEMD)" $(SYSTEMD_PATH)
	@echo "Enabling $(XORG_SYSTEMD), however you should manually start it yourself..."
	$(SYSTEMCTL_PROGRAM) enable $(XORG_SYSTEMD)

install_mythtv:
	@$(CHK_DIR_EXISTS) $(LOGROTATE_PATH)  || $(MKDIR) $(LOGROTATE_PATH)
	@$(CHK_DIR_EXISTS) $(MYTHTV_LOG_PATH) || $(MKDIR) $(MYTHTV_LOG_PATH)
	$(INSTALL_CONFIG) "logrotate/$(MYTHTV_LOGROTATE)" $(LOGROTATE_PATH)
	$(INSTALL_CONFIG) "systemd/system/$(MYTHBACKEND_SYSTEMD)" $(SYSTEMD_PATH)
	@echo "Enabling $(MYTHBACKEND_SYSTEMD), however you should manually start it yourself..."
	$(SYSTEMCTL_PROGRAM) enable $(MYTHBACKEND_SYSTEMD)
	$(INSTALL_CONFIG) "systemd/system/$(MYTHFRONTEND_SYSTEMD)" $(SYSTEMD_PATH)
	@echo "Enabling $(MYTHFRONTEND_SYSTEMD), however you should manually start it yourself..."
	$(SYSTEMCTL_PROGRAM) enable $(MYTHFRONTEND_SYSTEMD)



uninstall_backup:
	-$(DEL_FILE)  $(SBIN_PATH)/$(BACKUP_SH)
	-$(DEL_FILE)  $(CONFIG_PATH)/$(BACKUP_CONFIG)
	-$(DEL_FILE)  $(LOGROTATE_PATH)/$(BACKUP_LOGROTATE)
	-$(DEL_DIR)   $(SBIN_PATH)
	-$(DEL_DIR)   $(CONFIG_PATH)

uninstall_usbdiskmount:
	-$(DEL_FILE)  $(BIN_PATH)/$(USBDISKMOUNT_SH)
	-$(DEL_FILE)  $(CONFIG_PATH)/$(USBDISKMOUNT_CONFIG)
	-$(DEL_FILE)  $(SYSTEMD_PATH)/$(USBDISKMOUNT_SYSTEMD)
	-$(DEL_FILE)  $(UDEV_PATH)/$(USBDISKMOUNT_UDEV)
	-$(DEL_FILE)  $(LOGROTATE_PATH)/$(USBDISKMOUNT_LOGROTATE)
	-$(DEL_DIR)   $(BIN_PATH)
	-$(DEL_DIR)   $(CONFIG_PATH)
	@echo "Reloading udev..."
	$(RELOAD_UDEV)

uninstall_php_cgi:
	@echo "Stopping $(PHP_CGI_SYSTEMD)..."
	-$(SYSTEMCTL_PROGRAM) stop $(PHP_CGI_SYSTEMD)
	-$(SYSTEMCTL_PROGRAM) disable $(PHP_CGI_SYSTEMD)
	-$(DEL_FILE)  $(SYSTEMD_PATH)/$(PHP_CGI_SYSTEMD)

uninstall_xorg:
	@echo "Disabling $(XORG_SYSTEMD)..."
	$(SYSTEMCTL_PROGRAM) stop $(XORG_SYSTEMD)
	$(SYSTEMCTL_PROGRAM) disable $(XORG_SYSTEMD)
	-$(DEL_FILE)  $(SYSTEMD_PATH)/$(XORG_SYSTEMD)
	-$(DEL_FILE)  $(SBIN_PATH)/$(XORGLOGIN_SH)

uninstall_mythtv:
	@echo "Disabling $(MYTHBACKEND_SYSTEMD)..."
	$(SYSTEMCTL_PROGRAM) stop $(MYTHBACKEND_SYSTEMD)
	$(SYSTEMCTL_PROGRAM) disable $(MYTHBACKEND_SYSTEMD)
	@echo "Disabling $(MYTHFRONTEND_SYSTEMD)..."
	$(SYSTEMCTL_PROGRAM) stop $(MYTHFRONTEND_SYSTEMD)
	$(SYSTEMCTL_PROGRAM) disable $(MYTHFRONTEND_SYSTEMD)
	-$(DEL_FILE) $(SYSTEMD_PATH)/$(MYTHBACKEND_SYSTEMD)
	-$(DEL_FILE) $(SYSTEMD_PATH)/$(MYTHFRONTEND_SYSTEMD)
	-$(DEL_FILE) $(LOGROTATE_PATH)/$(MYTHTV_LOGROTATE)
