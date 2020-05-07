#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QGraphicsScene>
#include <QFileDialog>
#include <QPen>
#include <QBrush>
#include <QMainWindow>
#include <QTimer>
#include <QMessageBox>

#include <iostream>

#include "ISKN_API.h"
#include <QInputDialog>


namespace Ui {
class WritingWindow;
}


class WritingWindow : public QMainWindow, public ISKN_API::Listener
{
    Q_OBJECT

public:
    explicit WritingWindow(QWidget *parent = 0);
    ~WritingWindow();

    void processEvent(ISKN_API::Event &e, unsigned int timecode);
    void connectionStatusChanged(bool);

signals:
    void updateStatus(QString text);
    void move(float x, float y, float z, bool touch, bool transition,int toolID);
    void sendHardwareEvent(int deviceFunction);
    void slateNameChanged(QString newName);

public slots:
    void onUpdateStatus(QString text);
    void onSlateNameChanged(QString newName);

private slots:
    void checkConnection();
    void receiveDeviceFunction(int deviceFunction);
    void onMove(float x, float y, float z, bool touch, bool transition, int toolID);

    void on_actionNew_triggered();
    void on_actionSave_as_triggered();
    void on_actionZoom_in_triggered();
    void on_actionZoom_out_triggered();
    void on_actionQuit_triggered();
    void on_actionRotation_a_gauche_triggered();
    void on_actionRotation_a_droite_triggered();

    void on_actionSet_Device_ID_triggered();


private:
    Ui::WritingWindow *ui;

    // ISKN API Attributes
    ISKN_API::SlateManager   *iskn_SlateManager;
    ISKN_API::Device      *iskn_Device;  

    bool isHandShakeActive;
    bool transition;
    bool back_Touch;

    int toolID;
    bool changing_device_id;

    float zoom;
    float xOffset,yOffset,coordScale;

    double penCurrentPosX;
    double penCurrentPosY;
    double penLastPosX;
    double penLastPosY;

    QPen defaultPen,redPen,bluePen,blackPen;
    QBrush writingBrush,redBrush,blueBrush,blackBrush;

    QTimer connexionTimer;
    QGraphicsScene *m_graphScen;
};

#endif // MAINWINDOW_H
