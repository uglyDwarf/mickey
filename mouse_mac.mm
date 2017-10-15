#include "mouse.h"
#include <QMutex>
#include <QMessageBox>
#include <QApplication>
#include <QDesktopWidget>
#include <ApplicationServices/ApplicationServices.h>
#include <QGuiApplication>
#include <QtGlobal>
#include <QScreen>

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

static QPoint confineToScreen(QPoint p) {
  // TODO: This function doesn't work perfectly for multiple screens because finding the closest point
  // on the boundary of multiple rectangles would take a while to figure out.
  // This allows it to kind of work by accepting points that are in non-primary screen.
  foreach (QScreen *screen, QGuiApplication::screens()) {
    if(screen->geometry().contains(p)) return p;
  }

  QRect geom = QGuiApplication::primaryScreen()->geometry();
  QPoint res;
  res.setX(qMax(geom.left(), qMin(p.x(), geom.right())));
  res.setY(qMax(geom.top(), qMin(p.y(), geom.bottom())));
  return res;
}

struct mouseLocalData{
  mouseLocalData():pressed((buttons_t)0){}
  buttons_t pressed;
  QMutex mutex;
};

mouseClass::mouseClass(){
  // Without this line, App Nap will eventually activate, stopping tracking.
  // Even worse, it seems to reactivate on click events, but without data, moving the mouse to (0,0)
  // This doesn't keep track of the activity, because we never need to disable it.
  [[NSProcessInfo processInfo] beginActivityWithOptions: NSActivityUserInitiated reason:@"Head Tracking"];

  data = new mouseLocalData();
}
  
mouseClass::~mouseClass(){
  delete data;
}

bool mouseClass::init()
{
  return true;
}

bool mouseClass::move(int dx, int dy)
{
  //Gotcha - when a key is pressed, while moving, emit not mouse moved, but mouse dragged event
  data->mutex.lock();
  CGEventType event;
  CGEventRef ev_ref;
  QPoint pos = QCursor::pos();
  pos = QPoint(pos.x() + dx, pos.y() + dy);
  pos = confineToScreen(pos);
  
  int pressed = [NSEvent pressedMouseButtons];
  if(pressed & LEFT_BUTTON){
    event = kCGEventLeftMouseDragged;
  } else if(pressed & RIGHT_BUTTON){
    event = kCGEventRightMouseDragged;
  } else {
    event = kCGEventMouseMoved;
  }

  ev_ref = CGEventCreateMouseEvent(NULL, event, CGPointMake(pos.x(),pos.y()), kCGMouseButtonLeft);
  CGEventPost(kCGHIDEventTap, ev_ref);
  CFRelease(ev_ref);
  
  QCursor::setPos(pos.x(), pos.y());
  data->mutex.unlock();
  return true;
}

bool mouseClass::click(buttons_t buttons, struct timeval ts)
{
  (void) ts;
  data->mutex.lock();
  buttons_t changed = (buttons_t)(buttons ^ data->pressed);
  CGEventType event;
  CGEventRef ev_ref;
  CGPoint pos;
  QPoint currentPos = QCursor::pos();
  pos.x = currentPos.x();
  pos.y = currentPos.y();
  if(changed & LEFT_BUTTON){
    if(buttons & LEFT_BUTTON){
      event = kCGEventLeftMouseDown;
    }else{
      event = kCGEventLeftMouseUp;
    }
    ev_ref = CGEventCreateMouseEvent(NULL, event, pos, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, ev_ref);
    CFRelease(ev_ref);
  }
  if(changed & RIGHT_BUTTON){
    if(buttons & RIGHT_BUTTON){
      event = kCGEventRightMouseDown;
    }else{
      event = kCGEventRightMouseUp;
    }
    CGEventCreateMouseEvent(NULL, event, pos, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, ev_ref);
    CFRelease(ev_ref);
  }
  data->pressed = buttons;
  data->mutex.unlock();
  return true;
}

/*
Possible leads:

https://developer.apple.com/library/mac/#documentation/graphicsimaging/reference/Quartz_Services_Ref/Reference/reference.html
http://stackoverflow.com/questions/11860285/opposit-of-cgdisplaymovecursortopoint
https://developer.apple.com/library/mac/#documentation/Carbon/Reference/QuartzEventServicesRef/Reference/reference.html
http://stackoverflow.com/questions/1483657/performing-a-double-click-using-cgeventcreatemouseevent
*/
