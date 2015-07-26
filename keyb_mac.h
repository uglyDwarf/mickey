#ifndef KEYB_MAC__H
#define KEYB_MAC__H

#include <QKeySequence>

class shortcut;


bool setShortCut(const QKeySequence &s, shortcut* id);
bool unsetShortcut(shortcut* id);


#endif