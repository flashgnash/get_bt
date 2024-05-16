extern crate blurz;

use std::error::Error;
use blurz::BluetoothAdapter;
use blurz::BluetoothDevice;
use blurz::BluetoothSession;

fn main() -> Result<(), Box<dyn Error>> {
    let session = BluetoothSession::create_session(None)?;
    let adapter = BluetoothAdapter::init(&session)?;

    let device_list = adapter.get_device_list()?;

    let mut connected_devices = Vec::new();
    let mut disconnected_devices = Vec::new();

    for path in device_list.iter() {
        let device = BluetoothDevice::new(&session, path.to_string());

        let device_name = device.get_name()?;
        let mac = device.get_address()?;
        let connected = device.is_connected()?;

        let device_formatted = format!("{}|{}", device_name, mac);

        if connected {
            connected_devices.push(format!(" {}", device_formatted));
        } else {
            disconnected_devices.push(format!(" {}", device_formatted));
        }
    }

    for device in connected_devices {
        println!("{}", device);
    }
    
    if !connected_devices.is_empty() {
        println!("-----------|");
    }
    
    for device in disconnected_devices {
        println!("{}", device);
    }

    Ok(())
}
