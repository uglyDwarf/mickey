#ifdef HAVE_CONFIG_H
  #include "../../config.h"
#endif

#include <QSettings>
#include <QRegExp>
#include <QDesktopServices>

#include "help_view.h"
#include "iostream"
#include "utils.h"

HelpViewer *HelpViewer::hlp = NULL;

HelpViewer &HelpViewer::getHlp()
{
  if(hlp == NULL){
    hlp = new HelpViewer();
  }
  return *hlp;
}

void HelpViewer::ShowWindow()
{
  getHlp().show();
}

void HelpViewer::RaiseWindow()
{
  getHlp().raise();
  getHlp().activateWindow();
}

void HelpViewer::ChangePage(QString name)
{
  getHlp().ChangeHelpPage(name);
}


static QString getDataPath(QString file)
{
  char *path = ltr_int_get_data_path_prefix(file.toUtf8().constData(),                                            QApplication::applicationDirPath().toUtf8().constData());
  QString res = QString::fromUtf8(path);
  free(path);
  return res;
}


void HelpViewer::ChangeHelpPage(QString name)
{
  QString tmp = QString::fromUtf8("file://") + getDataPath(QString::fromUtf8("/help/") + 
                  QString::fromUtf8(HELP_BASE) + name);
//  viewer->load(QUrl(tmp));
}

void HelpViewer::CloseWindow()
{
  getHlp().close();
}

void HelpViewer::LoadPrefs(QSettings &settings)
{
  HelpViewer &hv = getHlp();
  settings.beginGroup(QString::fromUtf8("HelpWindow"));
  hv.resize(settings.value(QString::fromUtf8("size"), QSize(800, 600)).toSize());
  hv.move(settings.value(QString::fromUtf8("pos"), QPoint(0, 0)).toPoint());
  settings.endGroup();
}

void HelpViewer::StorePrefs(QSettings &settings)
{
  HelpViewer &hv = getHlp();
  settings.beginGroup(QString::fromUtf8("HelpWindow"));
  settings.setValue(QString::fromUtf8("size"), hv.size());
  settings.setValue(QString::fromUtf8("pos"), hv.pos());
  settings.endGroup();
}

HelpViewer::HelpViewer(QWidget *parent) : QWidget(parent), contents(NULL), layout(NULL)
{
  ui.setupUi(this);
  setWindowTitle(QString::fromUtf8("Help viewer"));
//  viewer = new QWebView(this);
  contents = new QListWidget(this);
  ReadContents();
  layout = new QHBoxLayout();
  splitter = new QSplitter();
  layout->addWidget(splitter);
  splitter->addWidget(contents);
//  splitter->addWidget(viewer);
  ui.verticalLayout->insertLayout(0, layout);
  QObject::connect(contents, SIGNAL(currentTextChanged(const QString &)), 
                   this, SLOT(currentTextChanged(const QString &)));
  
//  QObject::connect(viewer, SIGNAL(linkClicked(const QUrl&)), this, SLOT(followLink(const QUrl&)));
//  viewer->page()->setLinkDelegationPolicy(QWebPage::DelegateAllLinks);
}

bool HelpViewer::ReadContents()
{
  QFile contentsFile(getDataPath(QString::fromUtf8("/help/") + 
    QString::fromUtf8(HELP_BASE) + QString::fromUtf8("contents.txt")));
  if(!contentsFile.open(QFile::ReadOnly)){
    return false;
  }
  bool res = false;
  QTextStream contents(&contentsFile);
  QString line;
  QRegExp pattern(QString::fromUtf8("^\"([^\"]+)\"\\s+\"([^\"]+)\"$"));
  QStringList captured;
  while(!(line = contents.readLine()).isNull()){
    if(pattern.exactMatch(line)){
      captured = pattern.capturedTexts();
      if(captured.length() == 3){
        addPage(captured[2], captured[1]);
        res = true;
      }
    }
  }
  return res;
}

void HelpViewer::addPage(QString name, QString page)
{
  pages[name] = page;
  contents->addItem(name);
}

void HelpViewer::currentTextChanged(const QString &currentText)
{
  ChangeHelpPage(pages[currentText]);
}

void HelpViewer::on_CloseButton_pressed()
{
  close();
}

void HelpViewer::followLink(const QUrl &url)
{
  if(QString::fromUtf8("http").compare(url.scheme(), Qt::CaseInsensitive) == 0){
    QDesktopServices::openUrl(url);
  }else{
//    viewer->load(url);
  }
}

HelpViewer::~HelpViewer()
{
  ui.verticalLayout->removeItem(layout);
  layout->removeWidget(contents);
//  layout->removeWidget(viewer);
  delete(layout);
  delete(contents);
//  delete(viewer);
}

