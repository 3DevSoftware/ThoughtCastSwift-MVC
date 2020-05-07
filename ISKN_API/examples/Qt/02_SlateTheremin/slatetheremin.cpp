#include "slatetheremin.h"
#include "ui_slatetheremin.h"

using namespace ISKN_API;
using namespace std;

SlateTheremin::SlateTheremin(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    pos_x(0),
    pos_y(0),
    last_phase(0)
{
    ui->setupUi(this);

    // Create buffer
    audio_outputBuffer = new short[BUF_TEST];

    try
    {
        cout<<"Attempting to connect to iSketchnote device..."<<endl;

        // Create iskn_SlataManager and Device
        iskn_SlataManager = new SlateManager();
        iskn_Device     = &iskn_SlataManager->getDevice();

        // Register events Listener
        iskn_SlataManager->registerListener(this);

        // Connect to the Slate
        if (iskn_SlataManager->connect())
        {
            cout<<"Scanning devices..."<<endl;
        }
        else
        {
            QMessageBox::critical(this, tr("Error"), tr("Slate is not connected. Check your USB connection."));
            cout<<"Could not connect..."<<endl;
            exit(0);
        }
    }
    catch (Error &err)
    {
        wcout << err.Message() << endl;
    }
}

SlateTheremin::~SlateTheremin()
{
    delete ui;
}


void SlateTheremin::play_sample() {
    // Create the player
    sound_sample_player = new QMediaPlayer(this);

    // Clear playback speed
    ui->box_playback_speed->setValue(1.0);

    // Clear playlist
    sound_sample_playlist.clear();

    // Add the sample to the playlist
    sound_sample_playlist.addMedia(QMediaContent(QUrl::fromLocalFile(samplesPath + "/" + ui->list_sample->currentText())));
    sound_sample_playlist.setPlaybackMode(QMediaPlaylist::CurrentItemInLoop);

    // Play the sample
    sound_sample_player->setPlaylist(&sound_sample_playlist);
    sound_sample_player->setPlaybackRate(1.0);
    sound_sample_player->play();
}


void SlateTheremin::stop_sample() {
    sound_sample_player->stop();
    delete sound_sample_player;
    sound_sample_player = 0;
}


void SlateTheremin::refresh_sample_list() {
    QStringList items;

    ui->list_sample->clear();

    if(samplesPath.isEmpty())
        samplesPath = QFileDialog::getExistingDirectory(this, tr("Sample path"), QCoreApplication::applicationDirPath());

    if(samplesPath.isEmpty() == false) {
        ui->pb_refresh_sample_list->setIcon(QIcon(":/icons/refresh"));
        QDir l_path(samplesPath);
        items = l_path.entryList(QStringList(), QDir::Files | QDir::NoDot | QDir::NoDotDot);

        ui->list_sample->addItems(items);
    }
}


void SlateTheremin::connectionStatusChanged(bool connected)
{
    if(connected) {

        // Request Slate description
        iskn_SlataManager->request(REQ_DESCRIPTION);

        // Subscribe to events (Status, Pen Status, Function Call and Pen_3D)
        iskn_SlataManager->subscribe(
                    AUTO_STATUS |
                    AUTO_SOFTWARE_EVENTS |
                    AUTO_HARDWARE_EVENTS |
                    AUTO_PEN_3D
                    );

        // Set up the format
        QAudioFormat format;
        format.setSampleRate(SAMPLE_RATE);
        format.setChannelCount(1);
        format.setSampleSize(SAMPLE_SIZE);
        format.setCodec("audio/pcm");
        format.setByteOrder(QAudioFormat::LittleEndian);
        format.setSampleType(QAudioFormat::SignedInt);

        // Create audio output stream, set up signals
        audio_outputStream = new QAudioOutput(format, this);
        audio_outputDevice = audio_outputStream->start();

        streaming_timer.setInterval(FREQ_UPDATE_MS);
        connect(&streaming_timer, SIGNAL(timeout()), this, SLOT(processAudio()));
        streaming_timer.start();
    }
    else
    {
        streaming_timer.stop();
    }
}


double SlateTheremin::generate_tone(short *buf, float x, float y , double phase) {
    double deltaRad = 0;
    double nbPeriods,newPhase;

    // Calcul frequency regard of the position of the pen
    double freq_min = ui->slider_freq_min->value();     // default is 200Hz
    double freq_max = ui->slider_freq_max->value();     // default is 2kHz
    double freq_hz = (((freq_max-freq_min)/100)*y) + freq_min;

    // Calcul amplitude regard of the position of the pen
    double amp_min = (((32767)/100)*ui->slider_sound_min->value());
    double amp_max = (((32767)/100)*ui->slider_sound_max->value());
    double amp_bit = (((amp_max-amp_min)/100)*x) + amp_min;

    deltaRad =  2.0*M_PI*freq_hz / SAMPLE_RATE;

    for(unsigned long i=0 ; i < BUF_TEST ; i++)
    {
        // Sine waveform
        if(ui->waveform_sine->isChecked()) {
            buf[i] = amp_bit * sin((i)*deltaRad + phase);
        }
        // Sine distorted waveform
        else if(ui->waveform_distord_sine->isChecked()) {
            if(qAbs(amp_bit * sin((i)*deltaRad + phase)) < amp_bit/1.5)
                buf[i] = amp_bit * sin((i)*deltaRad + phase);
            else
                buf[i] = amp_bit;
        }
        // Square waveform
        else if(ui->waveform_square->isChecked()) {
            if(sin((i)*deltaRad + phase) < 0)
                buf[i] = -amp_bit;
            else
                buf[i] = amp_bit;
        }
    }

    newPhase = (BUF_TEST)*deltaRad + phase;
    nbPeriods = floor(newPhase / (2.0*M_PI));

    return newPhase - ( nbPeriods * 2.0 * M_PI );
}


void SlateTheremin::processAudio() {
    if(audio_outputDevice->isOpen() && audio_outputStream->state() != QAudio::StoppedState) {
        // Generate tone and "keep" the phase in "last_phase"
        last_phase = this->generate_tone(audio_outputBuffer, this->pos_x, this->pos_y, last_phase);

        // Write our buffer to the QAudioOutput buffer
        audio_outputDevice->write((char *)audio_outputBuffer, BUF_TEST * sizeof(short));
    }
}


void SlateTheremin::processEvent(Event &e, unsigned int timecode)
{
    Q_UNUSED(timecode); // Ignore warning

    switch (e.Type)
    {
    case EVT_STATUS:
        cout<<"Battery : "<<iskn_Device->getBatteryCharge()<<endl;
        break ;

    case EVT_DESCRIPTION:
        {
            cout<<"Device name: "<<iskn_Device->getDeviceName()<<endl;
            Rect descr = e.Description.getActiveZone();
            this->ClientWidth = descr.Width;
            this->ClientHeight = descr.Height;
            this->ClientLeft = descr.Left;
            this->ClientTop = descr.Top;
        }
        break;

    case EVT_SOFTWARE:
        switch (e.SoftwareEvent.getSoftwareEventType())
        {
        case SE_OBJECT_IN :
            break ;

        case SE_OBJECT_OUT :
            if(ui->sound_when_no_pen->isChecked() == false) {
                this->pos_x = 0;
                this->pos_y = 0;
            }
            break ;

        case SE_HANDSHAKE :
            break ;
        }
        break ;

    case EVT_HARDWARE :
        cout<<"EVT_HARDWARE"<<endl;
        break ;

    case EVT_PEN_3D :
        {
            float rel_pos_x = 0, rel_pos_y = 0;
            rel_pos_x = ((e.Pen3D.getPosition().X - this->ClientLeft) / this->ClientWidth) *100;
            rel_pos_y = ((e.Pen3D.getPosition().Y - this->ClientTop) / this->ClientHeight) *100;

            // Rejecting when outside of area
            if(rel_pos_x <= 0.0)    rel_pos_x = 0.0;
            if(rel_pos_x >= 100.0)  rel_pos_x = 100.0;
            if(rel_pos_y <= 0.0)    rel_pos_y = 0.0;
            if(rel_pos_y >= 100.0)  rel_pos_y = 100.0;

            rel_pos_y = 100-rel_pos_y;

            if((ui->sound_update_only_pen_touch->isChecked() && e.Pen3D.Touch() == true) ||
                    ui->sound_update_pen_on_sight->isChecked()) {
                this->pos_x = rel_pos_x;
                this->pos_y = rel_pos_y;
            }
            else {
                if(ui->sound_no_maintain->isChecked() && ui->sound_update_only_pen_touch->isChecked()) {
                    this->pos_x = 0;
                    this->pos_y = 0;
                }
            }
        }
        break ;

    default:
        if (e.Type>=EVT_ERROR)
            cout<<"Event : "<<(int)e.Type<<endl;
        break ;
    }
}


void SlateTheremin::on_slider_freq_min_valueChanged(int value)
{
    if(value >= ui->slider_freq_max->value()) {
        value = ui->slider_freq_max->value()-1;
        ui->slider_freq_min->setValue(value);
    }

    ui->label_freq_min->setText(QString(QString::number(value) + " Hz"));
}

void SlateTheremin::on_slider_freq_max_valueChanged(int value)
{
    if(value <= ui->slider_freq_min->value()) {
        value = ui->slider_freq_min->value()+1;
        ui->slider_freq_max->setValue(value);
    }

    ui->label_freq_max->setText(QString(QString::number(value) + " Hz"));
}

void SlateTheremin::on_slider_sound_min_valueChanged(int value)
{
    if(value >= ui->slider_sound_max->value()) {
        value = ui->slider_sound_max->value()-1;
        ui->slider_sound_min->setValue(value);
    }

    ui->label_sound_min->setText(QString(QString::number(value) + " %"));
}

void SlateTheremin::on_slider_sound_max_valueChanged(int value)
{
    if(value <= ui->slider_sound_min->value()) {
        value = ui->slider_sound_min->value()+1;
        ui->slider_sound_max->setValue(value);
    }

    ui->label_sound_max->setText(QString(QString::number(value) + " %"));
}


void SlateTheremin::on_pb_play_stop_clicked()
{
    if(ui->pb_play_stop->text().contains("Play")) {
        ui->pb_play_stop->setText("Stop");
        play_sample();
    }
    else {
        ui->pb_play_stop->setText("Play");
        stop_sample();
    }
}

void SlateTheremin::on_pb_refresh_sample_list_clicked()
{
    refresh_sample_list();
}

void SlateTheremin::on_box_playback_speed_valueChanged(double playback_speed)
{
    sound_sample_player->setPlaybackRate(playback_speed);
}
