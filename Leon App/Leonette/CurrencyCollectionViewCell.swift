//
//  CurrencyCollectionViewCell.swift
//  Leonette
//
//  Created by Vian Nguyen on 1/15/21.
//

import UIKit

class CurrencyCollectionViewCell: UICollectionViewCell {
    
    var currencyLabel: UILabel!
    var amountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemIndigo
        makeRoundedAndShadowed()
        
        setupLabels()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(curLabel: String, amount: Int) {
        
        currencyLabel.text = curLabel + ":"
        amountLabel.text = String(amount)
        
    }
    
    func setupLabels() {
        currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.textColor = .white
        contentView.addSubview(currencyLabel)
        
        amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textColor = .white
        contentView.addSubview(amountLabel)
    
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            currencyLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10)
        ])
        NSLayoutConstraint.activate([
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 15),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func makeRoundedAndShadowed() {
        let shadowLayer = CAShapeLayer()
        
        contentView.layer.cornerRadius = 5
        shadowLayer.path = UIBezierPath(roundedRect: contentView.bounds,
                                        cornerRadius: contentView.layer.cornerRadius).cgPath
        shadowLayer.fillColor = contentView.backgroundColor?.cgColor
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shadowRadius = 5.0
        contentView.layer.insertSublayer(shadowLayer, at: 0)
    }

    
    
    
}
