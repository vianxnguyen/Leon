//
//  CameraViewController.swift
//  Leonette
//
//  Created by Vian Nguyen on 1/5/21.
//

import UIKit
import AVKit
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var dataOutput : AVCaptureVideoDataOutput!
    
    var captureImageButton: UIButton!
    var photoImageView: UIImageView!
    var pictureTaken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)

        
    }
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        //view.backgroundColor = .systemGray
        
        title = "Camera"
        setupCaptureSession()
        setupViews()
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }
    
    @objc func captureImage() {
        pictureTaken = true
        print("Taking photo.")
        
        
    }
    func makeRoundedAndShadowed(view: UIView) {
        let shadowLayer = CAShapeLayer()
        
        view.layer.cornerRadius = 5
        shadowLayer.path = UIBezierPath(roundedRect: view.bounds,
                                        cornerRadius: view.layer.cornerRadius).cgPath
        shadowLayer.fillColor = view.backgroundColor?.cgColor
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shadowRadius = 5.0
        view.layer.insertSublayer(shadowLayer, at: 0)
    }

    
    func setupViews() {
        photoImageView = UIImageView()
        //photoImageView.image = UIImage(named: "orange")
        
        captureImageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        captureImageButton.backgroundColor = .systemIndigo
        captureImageButton.setTitle("Take Picture", for: .normal)
        makeRoundedAndShadowed(view: captureImageButton)
                
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        captureImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(photoImageView)
        view.addSubview(captureImageButton)
        
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: captureImageButton.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: captureImageButton.topAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 50),
            photoImageView.widthAnchor.constraint(equalToConstant: 50),

            captureImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureImageButton.widthAnchor.constraint(equalToConstant: 200),
            captureImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        captureImageButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
    }
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input =  try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        
        captureSession.addOutput(dataOutput)
        dataOutput.connections.first?.videoOrientation = .portrait
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if !pictureTaken {
            return
        }
        
        //print("Capturing Output.")
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
                
        //get a CIImage out of the CVImageBuffer
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        //get UIImage out of CIImage
        let uiImage = UIImage(ciImage: ciImage)
        
        DispatchQueue.main.async {
            self.photoImageView.image = uiImage
            self.pictureTaken = false
            self.tabBarController?.selectedIndex = 1
            
        }
    }
    
    
}



    
