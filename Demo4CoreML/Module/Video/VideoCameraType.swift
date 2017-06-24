//
//  VideoCameraType.swift
//  Demo4CoreML
//
//  Created by Seven on 24/06/2017.
//  Copyright © 2017 Seven. All rights reserved.
//
//  Based on yulingtianxia's Code


import AVFoundation

enum CameraType : Int {
    case back
    case front
    
    func captureDevice() -> AVCaptureDevice? {
        switch self {
        case .front:
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: AVMediaType.video, position: .front).devices
            print("devices:\(devices)")
            for device in devices where device.position == .front {
                return device
            }
        default:
            break
        }

        return AVCaptureDevice.default(for: AVMediaType.video)
    }
}
