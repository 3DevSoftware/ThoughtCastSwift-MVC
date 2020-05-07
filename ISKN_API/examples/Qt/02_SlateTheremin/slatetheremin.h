#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <iostream>

#include <QMainWindow>
#include <QtMultimedia/QAudioOutput>
#include <QIODevice>
#include <QTimer>
#include <QtMath>
#include <QMessageBox>
#include <QDir>
#include <QFileDialog>
#include <QMediaPlayer>
#include <QMediaPlaylist>

#include "ISKN_API.h"

#define SAMPLE_RATE 44100.0
#define SAMPLE_SIZE 16
#define FREQ_UPDATE_MS 10.0
#define BUF_TEST (unsigned) (SAMPLE_RATE * (FREQ_UPDATE_MS/1000.0)) // if feeding @ 50Hz => BUF_TEST * 50 = SAMPLE_RATE


namespace Ui {
class MainWindow;
}

class SlateTheremin : public QMainWindow, public ISKN_API::Listener
{
    Q_OBJECT

public:
    explicit SlateTheremin(QWidget *parent = 0);
    ~SlateTheremin();

    void processEvent(ISKN_API::Event &e, unsigned int timecode);
    void connectionStatusChanged(bool connected);
    double generate_tone(short *, float, float, double phase);

    void refresh_sample_list();
    void play_sample();
    void stop_sample();

private slots:
    void processAudio();
    void on_slider_freq_min_valueChanged(int);
    void on_slider_freq_max_valueChanged(int);
    void on_slider_sound_min_valueChanged(int);
    void on_slider_sound_max_valueChanged(int);
    void on_pb_play_stop_clicked();
    void on_pb_refresh_sample_list_clicked();

    void on_box_playback_speed_valueChanged(double);

private:
    Ui::MainWindow *ui;

    // ==================================
    // ISKN API Attributes
    // ==================================
    ISKN_API::SlateManager  *iskn_SlataManager;
    ISKN_API::Device        *iskn_Device;
    // ==================================

    // ==================================
    // Slate info
    // ==================================
    unsigned short int ClientWidth;
    unsigned short int ClientHeight;
    unsigned short int ClientLeft;
    unsigned short int ClientTop;
    // ==================================

    // Update QIODevice buffer every timeout
    QTimer streaming_timer;

    // Audio buffer
    short *audio_outputBuffer;

    // Audio buffer used by QAudioOutput
    QIODevice *audio_outputDevice;

    // Audio device
    QAudioOutput *audio_outputStream;

    float pos_x, pos_y;
    float last_phase;

    // Sample
    QMediaPlayer *sound_sample_player;
    QMediaPlaylist sound_sample_playlist;
    QString samplesPath;
};

#endif // MAINWINDOW_H
