#include "WritingWindow.h"
#include "ui_WritingWindow.h"

using namespace std;
using namespace ISKN_API;

///-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-///
///
///                                                 WritingWindow class
///-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_///

WritingWindow::WritingWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::WritingWindow)
{
    ui->setupUi(this);

    zoom = 0.5;
    ui->drawingSheet->scale(zoom,zoom);

    m_graphScen = new QGraphicsScene;
    m_graphScen->setSceneRect(0,0,ui->drawingSheet->width()*2,ui->drawingSheet->height()*2);
    ui->drawingSheet->setRenderHint(QPainter::Antialiasing, true);
    ui->drawingSheet->setScene(m_graphScen);

    //Offset
    xOffset    = 76.0;
    yOffset    = 130.0;
    coordScale = 7.4;

    //Default pen
    writingBrush.setColor(Qt::gray);
    writingBrush.setStyle(Qt::SolidPattern);
    defaultPen.setBrush(writingBrush);
    defaultPen.setStyle(Qt::SolidLine);
    defaultPen.setCapStyle(Qt::RoundCap);
    defaultPen.setJoinStyle(Qt::RoundJoin);

    //Red Pen
    redBrush.setColor(Qt::red);
    redBrush.setStyle(Qt::SolidPattern);
    redPen.setBrush(redBrush);
    redPen.setStyle(Qt::SolidLine);
    redPen.setCapStyle(Qt::RoundCap);
    redPen.setJoinStyle(Qt::RoundJoin);
    redPen.setWidth(3);

    //Blue Pen
    blueBrush.setColor(Qt::blue);
    blueBrush.setStyle(Qt::SolidPattern);
    bluePen.setBrush(blueBrush);
    bluePen.setStyle(Qt::SolidLine);
    bluePen.setCapStyle(Qt::RoundCap);
    bluePen.setJoinStyle(Qt::RoundJoin);
    bluePen.setWidth(3);

    //Black Pen
    blackBrush.setColor(Qt::black);
    blackBrush.setStyle(Qt::SolidPattern);
    blackPen.setBrush(blackBrush);
    blackPen.setStyle(Qt::SolidLine);
    blackPen.setCapStyle(Qt::RoundCap);
    blackPen.setJoinStyle(Qt::RoundJoin);
    blackPen.setWidth(3);

    connect(this,SIGNAL(move(float,float,float,bool,bool,int)),this,SLOT(onMove(float , float , float,bool,bool,int)));
    connect(this,SIGNAL(sendHardwareEvent(int)),this,SLOT(receiveDeviceFunction(int)));
    connect(this,SIGNAL(updateStatus(QString)),this,SLOT(onUpdateStatus(QString)));
    connect(this,SIGNAL(slateNameChanged(QString)),this,SLOT(onSlateNameChanged(QString)));
    transition = true;
    back_Touch = false;
    changing_device_id = false;

    try
    {
        cout << "Attempting to connect to ISKN Slate ..." << endl;

        // Create Slate manager and Device
        iskn_SlateManager = new SlateManager();
        iskn_Device     = &iskn_SlateManager->getDevice();

        // Register events Listener
        iskn_SlateManager->registerListener(this);

        // Connect to the Slate
        if (!iskn_SlateManager->connect())
        {
            updateStatus("Could not Connect");
            cout << "Could not connect..." << endl ;
        }
           // Connection checking Timer
            isHandShakeActive=true;
            connexionTimer.setInterval(3000);
            connect(&connexionTimer,SIGNAL(timeout()),this,SLOT(checkConnection()));
            connexionTimer.start();
    }
    catch (Error &err)
    {
        wcout << err.Message() << endl;
    }

}

WritingWindow::~WritingWindow()
{
    delete ui;
}


void WritingWindow::connectionStatusChanged(bool connected)
{
    if(connected)
    {
        // Request Slate description
        iskn_SlateManager->request(REQ_DESCRIPTION);

        // Subscribe to events (Status event, Software events, Hardware events and Pen 3D event)
        iskn_SlateManager->subscribe(
                    AUTO_STATUS |
                    AUTO_SOFTWARE_EVENTS |
                    AUTO_HARDWARE_EVENTS |
                    AUTO_PEN_3D
                    );
    }
    else
    {
        connexionTimer.stop();
        connexionTimer.start();

    }
}


/**
 * \brief Clean the graphic scene
 */
void WritingWindow::on_actionNew_triggered()
{
    m_graphScen->clear();
}


/**
 * \brief Ask where and save the graphic scene
 */
void WritingWindow::on_actionSave_as_triggered()
{
    QString fileName = QFileDialog::getSaveFileName(this, tr("Save File"),"",tr("png Files (*.png)"));
    cout<<"File name : "<<fileName.toStdString()<<endl;
    if(!fileName.isEmpty())
    {
        QImage pixmap(ui->drawingSheet->width(), ui->drawingSheet->height(), QImage::Format_ARGB32_Premultiplied);
        QPainter p;
        p.begin(&pixmap);
        p.setRenderHint(QPainter::Antialiasing, true);
        ui->drawingSheet->render(&p);
        p.end();
        pixmap.save(fileName, "PNG");
    }
}


/**
 * \brief Zoom in x2 the graphic scene
 */
void WritingWindow::on_actionZoom_in_triggered()
{
    zoom=2;
    ui->drawingSheet->scale(zoom,zoom);
}


/**
 * \brief Zoom out x0.5 the graphic scene
 */
void WritingWindow::on_actionZoom_out_triggered()
{
    zoom=0.5;
    ui->drawingSheet->scale(zoom,zoom);
}


/**
 * \brief Close the window (quit)
 */
void WritingWindow::on_actionQuit_triggered()
{
   this->close();
}


/**
 * \brief Handle Slate buttons events
 *
 * \param deviceFunction: contain which button has been pressed
 */
void WritingWindow::receiveDeviceFunction(int deviceFunction)
{
    if(deviceFunction==2)
        m_graphScen->clear();
}


/**
 * \brief Handle pen move event
 *
 * \param   x: X coordonate of the pen
 *          y: Y coordonate of the pen
 *          z: Elevation coordonate of the pen
 *      touch: True if the pen touch the paper, otherwise false
 * transition: Save the precedent touching state
 *     toolID: Refer which pen is detected
 */
void WritingWindow::onMove(float x, float y, float z, bool touch, bool transition, int toolID)
{
    //Unused parameter
    Q_UNUSED(z);

    /// Setting Pen Color
    switch(toolID)
    {
    case 1: defaultPen=redPen;
        break;
    case 2: defaultPen=bluePen;
        break;
    case 3: defaultPen=redPen;
        break;
    case 4: defaultPen=blackPen;
        break;
    default: defaultPen=blackPen;
        break;
    }

    /// Writing
    penCurrentPosX = double((x-this->xOffset)*this->coordScale);
    penCurrentPosY = double((y-this->yOffset)*this->coordScale);

    if(touch && !transition)
    {
        m_graphScen->addLine(penLastPosX,penLastPosY,penCurrentPosX,penCurrentPosY,defaultPen);
    }
    penLastPosX=penCurrentPosX;
    penLastPosY=penCurrentPosY;
}


/**
 * \brief Rotate the view -90° (from right to left)
 */
void WritingWindow::on_actionRotation_a_gauche_triggered()
{
     ui->drawingSheet->rotate(-90);
}


/**
 * \brief Rotate the view 90° (from left to right)
 */
void WritingWindow::on_actionRotation_a_droite_triggered()
{
     ui->drawingSheet->rotate(90);
}


/**
 * \brief Put a text in the status bar
 *
 * \param text: The string to put in the status bar
 */
void WritingWindow::onUpdateStatus(QString text){
    ui->statusBar->showMessage(text);
}

void WritingWindow::onSlateNameChanged(QString newName)
{
    QMessageBox::information(this,"Device ID","Device ID changed successfully!!\nNew name :"+newName);
}


/**
 * \brief Check if the slate is still connected. If not, try to reconnect
 */
void WritingWindow::checkConnection()
{

    if(isHandShakeActive)
    {
        isHandShakeActive=false;
    }
    else
    {
        iskn_SlateManager->disconnect();
        if(iskn_SlateManager->connect()){
            iskn_SlateManager->subscribe(AUTO_STATUS | AUTO_SOFTWARE_EVENTS | AUTO_HARDWARE_EVENTS | AUTO_PEN_3D) ;
            //iskn_CommLayer->request(REQ_DESCRIPTION) ;
            // Slow down Timer (The handshake is done every 2s so the timer should have an interval higher than 2s)
            connexionTimer.setInterval(3000);
        }
        else
        {
            updateStatus("Connection lost");
            // Speedup Timer to detect device disponibility faster
            connexionTimer.setInterval(500);
        }
    }

}


/**
 * \brief Receive an event from the slate
 *
 * \param IncomingEvent: The event caught
 *           timecode_t: Relative time of the event
 */
void WritingWindow::processEvent(Event &e, timecode_t timecode)
{
    //Unused parameter
    Q_UNUSED(timecode);

    switch (e.Type)
    {
    case EVT_STATUS:
        cout<<"Battery : "<<iskn_Device->getBatteryCharge()<<endl;
        break ;
    case EVT_DESCRIPTION:
        if(changing_device_id)
        {
            slateNameChanged(QString::fromStdString(iskn_Device->getDeviceName()));
            updateStatus("Connected to "+QString::fromStdString(iskn_Device->getDeviceName()));
            changing_device_id=false;
        }
        else
        {
            updateStatus("Connected to "+QString::fromStdString(iskn_Device->getDeviceName()));
            cout<<"Device Name: "<<iskn_Device->getDeviceName()<<endl;
            cout<<"Firmware Version: "<<iskn_Device->getFirmwareVersion()<<endl;
        }
        break;
    case EVT_SOFTWARE:
        switch (e.SoftwareEvent.getSoftwareEventType())
        {
        case SE_OBJECT_IN :
            cout<<"Pen in : "<<e.SoftwareEvent.getObjectID()<<endl;
            toolID=e.SoftwareEvent.getObjectID();
            back_Touch=false;
            transition=true;
            break ;

        case SE_OBJECT_OUT :
            cout<<"Pen out : "<<e.SoftwareEvent.getObjectID()<<endl;
            break ;

        case SE_HANDSHAKE :
            isHandShakeActive=true;
            break ;

        case SE_UNKNOWN:
            // nothing to do
            break;
        }

        break ;

    case EVT_HARDWARE :
        cout<<"Hardware event type : "<<e.HardwareEvent.getHardwareEventType()<<endl;
        sendHardwareEvent(e.HardwareEvent.getHardwareEventType());
        break ;

    case EVT_PEN_3D :
    {
        Vector3D po=e.Pen3D.getPosition() ;
        transition=false;

        if (e.Pen3D.Touch())
        {
            if(!back_Touch)
                transition=true;
        }
        else
        {
            if(back_Touch)
                transition=true;
        }
        back_Touch=e.Pen3D.Touch();
        move(po.X,po.Y,po.Z,back_Touch,transition,toolID);
    }
        break ;
    default:
        if (e.Type>=EVT_ERROR)
        cout<<"Event : "<<(int)e.Type<<endl;
        break ;
    }
}




void WritingWindow::on_actionSet_Device_ID_triggered()
{
    bool ok;
    QString text = QInputDialog::getText(this, tr("New Name"),
                                         tr("Device Name (Only A-Z, a-z or 0-9, no space, no special characters):"), QLineEdit::Normal,
                                         QDir::home().dirName(), &ok);
    if (ok && !text.isEmpty())
    {
        changing_device_id=true;
        iskn_Device->setDeviceName((char *)text.toStdString().c_str());
        iskn_SlateManager->request(REQ_DESCRIPTION);
    }
}


