#include "keyb_mac.h"

bool setShortCut(const QKeySequence &s, shortcut* id)
{
  (void) s;
  (void) id;
  return true;
}
bool unsetShortcut(shortcut* id)
{
  (void) id;
  return true;
}
