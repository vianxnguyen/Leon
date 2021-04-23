//
//  DetectionViewController.swift
//  Leonette
//
//  Created by Vian Nguyen on 1/5/21.
//

import UIKit
import AVKit
import Vision

class DetectionViewController: UIViewController {
    
    
    var outputCollectionView: UICollectionView!
    let currencyCellReuseIdentifier = "currencyCellReuseIdentifier"
    let cellPadding: CGFloat = 25
    
//    let oneDollar = Currency(currencyName: "1 Dollar", currencyAmt: 1.00)
//    let fiveDollar = Currency(currencyName: "5 Dollar", currencyAmt: 5.00)
//    let tenDollar = Currency(currencyName: "10 Dollar", currencyAmt: 10.00)
//    let twentyDollar = Currency(currencyName: "20 Dollar", currencyAmt: 20.00)
//    let fiftyDollar = Currency(currencyName: "50 Dollar", currencyAmt: 50.00)
//    let hundredDollar = Currency(currencyName: "100 Dollar", currencyAmt: 100.00)
//
//    let oneCent = Currency(currencyName: "1 Cent", currencyAmt: 0.01)
//    let fiveCent = Currency(currencyName: "5 Cent", currencyAmt: 0.05)
//    let tenCent = Currency(currencyName: "10 Cent", currencyAmt: 0.10)
//    let twentyFiveCent = Currency(currencyName: "25 Cent", currencyAmt: 0.25)
//    let fiftyCent = Currency(currencyName: "50 Cent", currencyAmt: 0.50)
    
    
    var currencyDict = ["1 Dollar": 0, "5 Dollar": 0, "10 Dollar": 0, "20 Dollar": 0, "50 Dollar" : 0, "100 Dollar": 0, "1 Cent": 0, "5 Cent": 0, "10 Cent": 0, "25 Cent": 0, "50 Cent": 0]
    var currencyAmt = ["1 Dollar": 1.00, "5 Dollar": 5.00, "10 Dollar": 10.00, "20 Dollar": 20.00, "50 Dollar" : 50.00, "100 Dollar": 100.00, "1 Cent": 0.01, "5 Cent": 0.05, "10 Cent": 0.10, "25 Cent": 0.25, "50 Cent": 0.50]
    var currencyList : [String] = []
    
    var total = 0.0
    lazy var detectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MoneyDetection().model)
                
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processDetections(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    var photoImageView: UIImageView!
    var currencyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Detection"
        setupOutputView()
        currencyList = ["1 Dollar", "5 Dollar", "10 Dollar", "20 Dollar", "50 Dollar", "100 Dollar", "1 Cent", "5 Cent", "10 Cent", "25 Cent", "50 Cent"]
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)

        
    }
    override func viewDidAppear(_ animated: Bool) {
        setupImageView()
        setupConstraints()
        
//        for (key, _) in currencyDict {
//            currencyList.append(key)
//        }
//        print(currencyList)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }
    
    func setupImageView() {
        
        photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        makeRoundedAndShadowed(view: photoImageView)
        let barViewControllers = self.tabBarController?.viewControllers
        let svc = barViewControllers![0] as! CameraViewController
        photoImageView.image = svc.photoImageView.image
        
        view.addSubview(photoImageView)
        
        if let image = photoImageView.image {
            updateDetections(for: image)
        }
        
    }
    
    func setupOutputView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellPadding
        layout.minimumLineSpacing = cellPadding
        layout.scrollDirection = .vertical
        
        outputCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        outputCollectionView.backgroundColor = .white
        outputCollectionView.translatesAutoresizingMaskIntoConstraints = false
        outputCollectionView.dataSource = self
        outputCollectionView.delegate = self
        
        outputCollectionView.register(CurrencyCollectionViewCell.self, forCellWithReuseIdentifier: currencyCellReuseIdentifier)
        
        view.addSubview(outputCollectionView)
        
        currencyLabel = UILabel()
        currencyLabel.text = "placeholder"
        currencyLabel.textColor = .white
        currencyLabel.font = UIFont.systemFont(ofSize: 17)
        currencyLabel.textAlignment = .center
        currencyLabel.backgroundColor = .systemGreen
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        makeRoundedAndShadowed(view: currencyLabel)
        view.addSubview(currencyLabel)
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
    
    func resetCurrencyDictionary() {
        for (key, _) in currencyDict {
            currencyDict[key] = 0
        }
    }
    
    func sortCurrencyDictionary() {
        let sortedDict = currencyDict.sorted { $0.1 > $1.1 }
        //print(sortedDict)
        currencyList = []
        for value in sortedDict {
            currencyList.append(value.key)
        }
        //print(currencyList)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            photoImageView.heightAnchor.constraint(equalToConstant: 450),
            photoImageView.widthAnchor.constraint(equalToConstant: 32p0),
        ])
        
        NSLayoutConstraint.activate([
            outputCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outputCollectionView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: cellPadding),
            outputCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            outputCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            currencyLabel.widthAnchor.constraint(equalToConstant: 300),
            currencyLabel.heightAnchor.constraint(equalToConstant:50 )
            
        ])
    }
    
    func updateDetections(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = image.ciImage else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            do {
                try handler.perform([self.detectionRequest])
            } catch {
                print("Failed to perform detection.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processDetections(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to detect anything.\n\(error!.localizedDescription)")
                return
            }
        
            let detections = results as! [VNRecognizedObjectObservation]
            self.outputDetections(detections: detections)
        }
    }
    
    func outputDetections(detections: [VNRecognizedObjectObservation]) {
            resetCurrencyDictionary()
            total = 0
        
            guard let image = self.photoImageView?.image else {
                return
            }
            
            let imageSize = image.size
            let scale: CGFloat = 0
            UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

            image.draw(at: CGPoint.zero)

            for detection in detections {
                
                //print(detection.labels.map({"\($0.identifier) confidence: \($0.confidence)"}).joined(separator: "\n"))
                let first = detection.labels[0]
                //print("\(first.identifier) : \(first.confidence)")
                //print("------------")
                
                //update currency dictionary
                let currencyName = first.identifier
                
                if let amt = currencyDict[currencyName] {
                    currencyDict[currencyName] = amt + 1
                }
                
    //            The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
                let boundingBox = detection.boundingBox
                let rectangle = CGRect(x: boundingBox.minX*image.size.width, y: (1-boundingBox.minY-boundingBox.height)*image.size.height, width: boundingBox.width*image.size.width, height: boundingBox.height*image.size.height)
                UIColor(red: 0, green: 1, blue: 0, alpha: 0.4).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.photoImageView?.image = newImage
        
        sortCurrencyDictionary()
        outputCollectionView.reloadData()
        voiceOutput()
    }
    
    func voiceOutput() {
    
        let synthesizer = AVSpeechSynthesizer()
        let speech = getSpeechOutput()
        view.bringSubviewToFront(currencyLabel)
        currencyLabel.text = "Total: \(total)"
        let utterance = AVSpeechUtterance(string: speech)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
        
    }
    
    func getSpeechOutput() -> String {
        var output = ""
        if total > 0 {
            output += "I counted"
        }
        for (key, _) in currencyDict {
            let amt = currencyDict[key]!
            if amt > 0 {
                let value = currencyAmt[key]!
                let new = Double(amt) * value
                let numberString = spellOutNumber(number: amt)
                
                var addendum = "s"
                if String(key.suffix(6)) == "Dollar" {
                    addendum = " bill"
                    if amt > 1 {addendum += "s"}
                }
                
                output += (numberString + " " + key + addendum + ", ")
                total += new
            }
        }
        
        let totalString = String(total)
        let decimalPoint = totalString.firstIndex(of: ".")?.utf16Offset(in: totalString) ?? 1
        
        let dollars = Int(totalString[0...decimalPoint-1]) ?? 0
        let cents = Int(totalString[decimalPoint+1...totalString.count-1]) ?? 0
        
        print("Total String: " + totalString)
        print(decimalPoint)
        print(dollars)
        print(cents)
        
        
        let complete = spellOutNumber(number: dollars) + " dollars and " + spellOutNumber(number: cents) + " cents"
        
        print(complete)
        
        output += "The total is " + complete
        return output
    }
    
    func spellOutNumber(number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let numberString = formatter.string(from: NSNumber(value: number)) ?? "one"
        return numberString
    }
    
    

}

extension DetectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (outputCollectionView.frame.width - cellPadding) / 2.0
        let height = (outputCollectionView.frame.height) / 5.0
        return CGSize(width: width, height: height)
    }
    
    
}

extension DetectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension DetectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currencyCellReuseIdentifier, for: indexPath) as! CurrencyCollectionViewCell
        
        let curLabel = currencyList[indexPath.row]
        let amount = currencyDict[curLabel] ?? 0
        cell.configure(curLabel: curLabel, amount: amount)
        return cell
        
    }
    
}
extension String {
  subscript(_ i: Int) -> String {
    let idx1 = index(startIndex, offsetBy: i)
    let idx2 = index(idx1, offsetBy: 1)
    return String(self[idx1..<idx2])
  }

  subscript (r: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: r.lowerBound)
    let end = index(startIndex, offsetBy: r.upperBound)
    return String(self[start ..< end])
  }

  subscript (r: CountableClosedRange<Int>) -> String {
    let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
    let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
    return String(self[startIndex...endIndex])
  }
}
