//
//  SecondViewController.swift
//  test
//
//  Created by ios_school on 2/12/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, ColorPickerDelegate {
   
    public var currentColor: UIColor = .white {
        didSet {
            currentColorWithBrightness = currentColor
        }
    }
    var currentColorWithBrightness: UIColor = .white
    var colorHandler: ((UIColor) -> Void)?
    @IBOutlet weak var colorPickerField: ColorPickerView!
    @IBOutlet weak var outputColorField: UIView!
    @IBOutlet weak var hexField: UILabel!
    
    func setOutputViewColor(color: UIColor) {
        outputColorField.backgroundColor = color
        hexField.text = color.toHex()
    }
    
    func setLastUserChoiceColor(_ color: UIColor) {
        currentColor = color
        outputColorField.backgroundColor = color
    }
    
    func ColorColorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        setOutputViewColor(color: color)
        currentColor = color
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        colorHandler?(currentColorWithBrightness)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func brightnessSliderValue(_ sender: UISlider) {
        currentColorWithBrightness =  currentColor.colorWithBrightness(brightness: CGFloat(sender.value))
        setOutputViewColor(color: currentColorWithBrightness)
    }
    
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerField.delegate = self
        slider.isContinuous = false
        setOutputViewColor(color: currentColor)
    }
}


extension UIColor {

     public func colorWithBrightness(brightness: CGFloat) -> UIColor {
           var H: CGFloat = 0, S: CGFloat = 0, B: CGFloat = 0, A: CGFloat = 0
           if getHue(&H, saturation: &S, brightness: &B, alpha: &A) {
               B += (brightness - 1.0)
               B = max(min(B, 1.0), 0.0)
               return UIColor(hue: H, saturation: S, brightness: B, alpha: A)
           }
           return self
       }
}
