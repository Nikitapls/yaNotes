//
//  ColorPicker.swift
//  ColorPicker
//
//  Created by ios_school on 2/12/20.
//  Copyright © 2020 ios_school. All rights reserved.
//
import UIKit

protocol ColorPickerDelegate : NSObjectProtocol {
    func ColorColorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State)
}

@IBDesignable
class ColorPickerView : UIView {

    weak internal var delegate: ColorPickerDelegate?
    let saturationExponentTop: Float = 2.0
    let saturationExponentBottom: Float = 1.3

    @IBInspectable var elementSize: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public func setGestureRecognizers(recognizersArr recognizers: [UIGestureRecognizer]) {
        self.gestureRecognizers?.removeAll()
        for recognizer in recognizers {
            self.addGestureRecognizer(recognizer)
        }
    }
    
    private func initialize() {
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
        
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
    }

   override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: rect.height, by: elementSize) {
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
    }

    func getColorAtPoint(point:CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),y:elementSize * CGFloat(Int(point.y / elementSize)))
        var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
    : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    @objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            let point = gestureRecognizer.location(in: self)
            let color = getColorAtPoint(point: point)
            self.delegate?.ColorColorPickerTouched(sender: self, color: color, point: point, state:gestureRecognizer.state)
        }
    }
}
