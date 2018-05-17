//
//  LinedTextField.swift
//
//
//  
//  Copyright © 2017 Soft Industry. All rights reserved.
//

import UIKit

class LinedTextField: UITextField {
    
    var lineHeight: CGFloat = 1.0
    var activeColor: UIColor = VisualAppearance.userActiveTextFieldColor
    var inactiveColor: UIColor = .lightGray
    private let lineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configreView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configreView()
    }
    
    func configreView() {
        lineLayer.backgroundColor = inactiveColor.cgColor
        layer.addSublayer(lineLayer)
        borderStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = layer.bounds
        lineLayer.frame = CGRect(x: bounds.minX - 1.0, y: bounds.maxY - lineHeight * 2.0, width: bounds.width - 2.0 , height: lineHeight)
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            lineLayer.backgroundColor = activeColor.cgColor
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            lineLayer.backgroundColor = inactiveColor.cgColor
        }
        return result
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds:bounds).insetBy(dx: 0.0, dy: 6.0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds:bounds).insetBy(dx: 0.0, dy: 6.0)
    }
}
