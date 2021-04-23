//
//  ViewController.swift
//  Leonette
//
//  Created by Vian Nguyen on 1/5/21.
//

import UIKit
import AVFoundation

/*
func setupConstraints() {
    NSLayoutConstraint.activate([
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        startButton.heightAnchor.constraint(equalTo: view.heightAnchor),
        startButton.widthAnchor.constraint(equalTo: view.widthAnchor)
        
    ])
}
 */

class ViewController: UIViewController {
    
    var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //view.backgroundColor = .systemIndigo
        
       
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        startButton.backgroundColor = .systemIndigo
        startButton.setTitle("Start", for: .normal)
        view.addSubview(startButton)
        
        startButton.addTarget(self, action: #selector(presentViews), for: .touchUpInside)
        
        voiceDirections()
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.center = view.center
        
    }
    
    func voiceDirections() {
        let synthesizer = AVSpeechSynthesizer()
        let speech = "Press anywhere to start."
        let utterance = AVSpeechUtterance(string: speech)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    @objc func presentViews() {
        let tabBarVC = UITabBarController()
        
        //let vc1 = UINavigationController(rootViewController: CameraViewController())
        //let vc2 = UINavigationController(rootViewController: DetectionViewController())
        let vc1 = CameraViewController()
        let vc2 = DetectionViewController()
        
        vc1.title = "Camera"
        vc2.title = "Detect"
        
        tabBarVC.setViewControllers([vc1, vc2], animated: false)
        
        guard let items = tabBarVC.tabBar.items else {
            return
        }
        let images = ["camera", "doc.text.magnifyingglass"]
        
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
        
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
        
    }


}


