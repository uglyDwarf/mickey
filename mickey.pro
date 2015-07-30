######################################################################
# Automatically generated by qmake (2.01a) Sat Jul 9 20:54:06 2011
######################################################################

CONFIG += qt debug warn_on precompile_header
TEMPLATE = app
TARGET = mickey
DEPENDPATH += .
QT += webkit
contains(QT_VERSION, ^5.*){
       QT += webkitwidgets widgets
       DEFINES += QT5_OVERRIDES
}

RESOURCES = mickey.qrc
DEFINES += QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII

PRECOMPILED_HEADER = precomp_headers.h


#QXT += core gui
# Input
FORMS += mickey.ui calibration.ui chsettings.ui hotkey.ui hotkey_setup.ui logview.ui
SOURCES += main.cpp mickey.cpp math_utils.c piper.c keyb.cpp \
           transform.cpp help_view.cpp \
	    linuxtrack.c hotkey.cpp my_line_edit.cpp hotkey_setup_dlg.cpp utils.c \
	    ipc_utils.c
HEADERS += mickey.h utils.h math_utils.h ipc_utils.h linuxtrack.h \
           uinput_ifc.h piper.h keyb.h keyb_x11.h keyb_mac.h transform.h help_view.h \
           mouse.h hotkey.h my_line_edit.h hotkey_setup_dlg.h

QMAKE_CXXFLAGS += -DHELP_BASE="'\""mickey/"\"'" -DPACKAGE_VERSION="'\"0.0\"'"
QMAKE_CFLAGS += -DPACKAGE_VERSION="'\"0.0\"'" -DLIB_PATH="'\"LIB_PATH\"'"
#QMAKE_CXXFLAGS += $$(CXXFLAGS)
#QMAKE_CFLAGS += $$(CFLAGS)
#QMAKE_LFLAGS += $$(LDFLAGS)

unix:!macx {
  QMAKE_CXXFLAGS += -fvisibility=hidden -O2 -Wall -Wextra -Wformat -Wformat-security \
    --param ssp-buffer-size=4 -fstack-protector -D_FORTIFY_SOURCE=2
  QMAKE_CFLAGS += -fvisibility=hidden -O2 -Wall -Wextra -Wformat -Wformat-security \
    --param ssp-buffer-size=4 -fstack-protector -D_FORTIFY_SOURCE=2
  SOURCES += mouse_linux.cpp uinput_ifc.c keyb_x11.cpp
  LIBS += -lm -lX11 -ldl
  
  target.path = /tmp/mickey/bin
  help.path += /tmp/mickey/share/linuxtrack/help/mickey
  help.files += help/*
  INSTALLS += target help

  contains(QT_VERSION, ^5.*){
    QT += x11extras
  }
}

macx {
  SOURCES += mouse_mac.cpp keyb_mac.cpp
  QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.6
  QMAKE_MAC_SDK=macosx
  CONFIG+=x86_64
  LIBS += -lm -framework ApplicationServices
  help.path += mickey.app/Contents/Resources/linuxtrack/help/mickey
  help.files += help/*
  INSTALLS += data help
  ICON = linuxtrack.icns
  DEFINES += DARWIN
}

