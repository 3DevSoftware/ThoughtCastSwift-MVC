package com.iskn.androidtestapp;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import java.util.ArrayList;
import static android.view.View.GONE;
import static android.view.View.VISIBLE;


import com.iskn.isknApi.*;
import com.iskn.isknApi.events.*;
import com.iskn.isknApi.bleScanner.*;


public class MainActivity extends AppCompatActivity  implements Listener, BLE_Scan_Listener {

    // UI attributes

    Button btnScan;
    Button btnRefresh;
    Button btnDisconnect;
    ListView lstDevices;
    TextView txtInfos;
    TextView txtPos;
    TextView txtBattery;
    ScrollView svInfos;
    LinearLayout llConnection;
    ArrayAdapter<String> adapter;
    ArrayList<String> items = new ArrayList<String>();

    // API attributes

    private SlateManager slateManager;
    private Device device;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 456;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Request permission to access location
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
        }

        // Create SlateManager object
        slateManager=new SlateManager(this);

        // Register the MainActivity class as a listener
        slateManager.registerListener(this);


        // Retreive UI components
        btnScan=(Button)findViewById(R.id.btnScan);
        btnRefresh=(Button)findViewById(R.id.btnRefresh);
        btnDisconnect=(Button)findViewById(R.id.btnDisconnect);

        lstDevices=(ListView)findViewById(R.id.lstDevices);

        txtInfos=(TextView)findViewById(R.id.txtInfos);
        svInfos=(ScrollView)findViewById(R.id.svInfos);
        txtPos=(TextView)findViewById(R.id.txtPos);
        txtBattery=(TextView)findViewById(R.id.txtBattery);
        llConnection = (LinearLayout)findViewById(R.id.llConnection);

        // Prepare the list view to hold devices list
        adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, items);

        lstDevices.setAdapter(adapter);


        //  ===================================== //
        //         Create Buttons listeners
        //  ===================================== //

        btnScan.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                llConnection.setVisibility(View.GONE);

                // Rest the list content
                items.clear();
                adapter.notifyDataSetChanged();

                // Start scanning for devices
                slateManager.stopScan();
                slateManager.startScan(MainActivity.this);
                appendInfo("Scanning...\n");
            }
        });

        btnDisconnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                appendInfo("Disconnecting...\n");
                slateManager.disconnect();
            }
        });

        btnRefresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                device.refresh();
            }
        });

        // When a Slate is selected, we connect to it
        lstDevices.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                // Stop scanning
                slateManager.stopScan();

                // Connect to the selected device
                slateManager.connect(slateManager.getDeviceByIndex(position));
                btnScan.setVisibility(GONE);
                appendInfo("Connecting...\n");
            }
        });
    }

    // This method adds a new message to the information textview
    // It also scrolls down the textview container
    void appendInfo(String info)
    {
        txtInfos.setText(txtInfos.getText()+info);
        svInfos.fullScroll(View.FOCUS_DOWN);
    }

    //  ===================================== //
    //          Listener methods
    //  ===================================== //

    @Override
    public void connectionStatusChanged(final boolean connected) {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                if (connected) {
                    slateManager.request(SlateManager.SingleRequestBlockType.REQ_DESCRIPTION);
                    slateManager.request(SlateManager.SingleRequestBlockType.REQ_STATUS);
                    slateManager.subscribe(SlateManager.AutoBlockType.AUTO_STATUS.type() |
                            SlateManager.AutoBlockType.AUTO_PEN_3D.type() |
                            SlateManager.AutoBlockType.AUTO_HARDWARE_EVENTS.type() |
                            SlateManager.AutoBlockType.AUTO_SOFTWARE_EVENTS.type());// |
                    //SlateManager.AutoBlockType.AUTO_LOC_QUALITY.type());
                    device = slateManager.getDevice();
                    llConnection.setVisibility(View.VISIBLE);
                } else {
                    txtInfos.setText("");
                    appendInfo(txtInfos.getText() + "Disconnected from " + device.getDeviceName() + "\n");
                    llConnection.setVisibility(GONE);
                    btnScan.setVisibility(VISIBLE);
                }
            }
        });
    }

    @Override
    public void processEvent(final Event event, int i) {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                switch(event.getType()){

                    case EVT_STATUS: {
                        EventStatus evt = (EventStatus) event;
                        if(evt.getBattery()<10)
                            txtBattery.setTextColor(Color.RED);
                        else
                            if(evt.getBattery()<70)
                                txtBattery.setTextColor(Color.rgb(255,165,0));
                            else
                                txtBattery.setTextColor(Color.GREEN);

                        txtBattery.setText("Battery :"+evt.getBattery()+"%  "+(evt.isBatteryInCharge()==1?"Charging":""));
                        appendInfo( "Battery :" + evt.getBattery()+"%\n");
                        appendInfo( "Battery is charging ? " + (evt.isBatteryInCharge()==1?"Yes":"NO")+"\n");
                        break;
                    }
                    case EVT_DESCRIPTION: {
                        EventDescription evt = (EventDescription) event;
                        Rect activeZone=evt.getActiveZone();
                        Size SlateSize=evt.getSlateSize();
                        String name=evt.getDeviceName();
                        appendInfo( "Connected to " + name+"\n");
                        appendInfo( "Firmware version :" + evt.getFirmwareVersion()+"\n");

                        appendInfo( "Slate Size (mm): " +"  width : "+SlateSize.getWidth()+" height : "+SlateSize.getHeight()+"\n");
                        appendInfo( "Active Zone (mm): " +" left : "+activeZone.getLeft()+" top : "+activeZone.getTop()+" width : "+activeZone.getWidth()+" height : "+activeZone.getHeight()+"\n");

                        break;
                    }
                    case EVT_PEN_3D: {
                        EventPen3D evt = (EventPen3D) event;
                        Vector3D vec=evt.getPosition();
                        if(evt.Touch())
                            txtPos.setTextColor(Color.RED);
                        else
                            txtPos.setTextColor(Color.GREEN);
                        txtPos.setText("Pen 3D : " + "X: " +vec.getPosX() +", Y: "+vec.getPosY()+", Z: "+vec.getPosZ()+"\n");
                        break;
                    }

                    case EVT_SOFTWARE:{
                        EventSoftware evt = (EventSoftware) event;
                        switch(evt.getSoftwareEventType()){
                            case SE_OBJECT_IN:
                                appendInfo( "Pen "+ evt.getObjectID() +" in\n");
                                break;
                            case SE_OBJECT_OUT:
                                appendInfo( "Pen "+ evt.getObjectID() +" out\n");
                                break;
                        }
                        break;
                    }
                    case EVT_HARDWARE: {
                        EventHardware evt = (EventHardware) event;
                        switch (evt.getHardwareEventType()){
                            case HE_BUTTON1_PRESSED:
                                appendInfo( "Button 1 pressed\n");
                                break;
                            case HE_BUTTON2_PRESSED:
                                appendInfo( "Button 2 pressed\n");
                                break;
                            case HE_BUTTON1_LONGPRESS:
                                appendInfo( "Button 1 long pressed\n");
                                break;
                            case HE_BUTTON2_LONGPRESS:
                                appendInfo( "Button 2 long pressed\n");
                                break;
                            case HE_UNKNOWN:
                                appendInfo( "Unknown hardware event\n");
                                break;
                            case HE_REFRESH_DONE:
                                appendInfo( "Slate refresh is done\n");
                                break;
                            default:
                                // appendInfo( "Unknown hardware evnt \n");
                                break;
                        }
                        break;
                    }

                    case EVT_LOC_QUALITY:{
                        EventLocQuality evt=(EventLocQuality)event;
                        Log.i("disturbance",""+((EventLocQuality) event).getDisturbanceLevel());
                        Log.i("status",""+((EventLocQuality) event).getLocStatus());
                        break;
                    }
                }
            }
        });
    }

    //  ===================================== //
    //      Ble_Scan_Listener methods
    //  ===================================== //

    @Override
    public void newDeviceFound(final BluetoothDevice bluetoothDevice) {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final BluetoothDevice p_device=bluetoothDevice;

                appendInfo( "Device "+p_device.getName()+" found\n");
                if(p_device.getName()!=null) {
                    items.add(p_device.getName()+" : "+p_device.getAddress());
                }
                else
                {
                    items.add("No Name : "+p_device.getAddress());
                }
                adapter.notifyDataSetChanged();
            }
        });

    }

    @Override
    public void notify(final BleScanner_Event bleScanner_event, String info) {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                switch (bleScanner_event) {
                    case BLESCANNER_EVENT_BLE_NOT_SUPPORTED:
                        Toast.makeText(MainActivity.this,"BLE not supported on this device",Toast.LENGTH_LONG).show();
                        break;
                    case BLESCANNER_EVENT_ACTIVATION_REQUIRED:
                        Toast.makeText(MainActivity.this,"Please activate BLE on the device",Toast.LENGTH_LONG).show();
                        Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                        startActivityForResult(enableBtIntent, BleScanner.REQUEST_ENABLE_BT);
                        break;
                    case BLESCANNER_EVENT_BLE_SCAN_STARTED:
                        Toast.makeText(MainActivity.this,"Scan started",Toast.LENGTH_LONG).show();
                        break;
                }
            }
        });
    }

    protected void onActivityResult(int requestCode, int resultCode,
                                    Intent data) {
        if (requestCode == BleScanner.REQUEST_ENABLE_BT) {
            if (resultCode == Activity.RESULT_OK) {
                try {
                    slateManager.startScan(MainActivity.this);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public void scanFailed(int i) {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                llConnection.setVisibility(GONE);
                appendInfo("Scan Failed\n");
            }
        });

    }

    @Override
    public void scanFinished() {
        // All ISNK related handlers need to run their code on tne main thread if they touch the ui
        // since these methods are called from a worker thread
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                llConnection.setVisibility(GONE);
                appendInfo("Scan is stopped \n");
            }
        });
    }
}
