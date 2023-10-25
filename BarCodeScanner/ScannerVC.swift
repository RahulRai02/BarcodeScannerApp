//
//  ScannerVC.swift
//  BarCodeScanner
//
//  Created by Rahul Rai on 14/10/23.
//

import AVFoundation
import Foundation
import UIKit

enum CameraError: String{
    case invalidDeviceInput = "Something is wrong with the camera. We are unable to capture the input"
    case invalidScannedValue = "The value scanned is not valid. The app can only scan EAN-8 and EAN-13"
}


protocol ScannerVCDelegate: AnyObject{
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}


final class ScannerVC: UIViewController{
     
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate!
    
    
    init(scannerDelegate: ScannerVCDelegate!) {
        // Since we are initializing a view controller,we need to initialize a nib name and a bundle
        super.init(nibName: nil, bundle: nil)
        
        
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Entry point
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let previewLayer = previewLayer else {
            scannerDelegate.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
        

    }
    
    private func setupCaptureSession(){
        // Main logic
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate.didSurface(error: .invalidDeviceInput)
            return
        }
        
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        }catch{
            scannerDelegate.didSurface(error: .invalidDeviceInput)
            return
        }
        
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }else{
            scannerDelegate.didSurface(error: .invalidDeviceInput)
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput){
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
        }else{
            scannerDelegate.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
        
    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {
            scannerDelegate.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else{
            scannerDelegate.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else{
            scannerDelegate.didSurface(error: .invalidScannedValue)
            return
        }
        captureSession.stopRunning()
        scannerDelegate?.didFind(barcode: barcode)
        
    }
    
    
    
}
