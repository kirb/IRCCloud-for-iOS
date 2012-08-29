GO_EASY_ON_ME=1

include theos/makefiles/common.mk

APPLICATION_NAME = IRCCloud
IRCCloud_FILES = main.m lib/base64.c $(wildcard lib/*.m) $(wildcard *.mm)
IRCCloud_FRAMEWORKS = UIKit CoreGraphics CFNetwork Security QuartzCore

THEOS_BUILD_DIR = debs

include $(THEOS_MAKE_PATH)/application.mk

internal-stage::
	@find -L _/ -name "*~" -delete;exit 0
	@find -L _/ -name "*.plist" -or -name "*.strings" -not -xtype l -print0|xargs -0 plutil -convert binary1;exit 0

after-install::
	@echo "Installing..."
	@echo " iPad"
	@install.exec "killall IRCCloud";exit 0
	@install.exec "sblaunch ws.hbang.irccloud";exit 0
