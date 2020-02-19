//
//  ViewController.swift
//  test
//
//  Created by ios_school on 1/30/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    var currColorFromSecView: UIColor = .gray
    var lastColorChoice: DrawView?
    
    private var isFirstTap = true {
        didSet {
            tapColorPicker.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastColorChoice = currentColor
        setBorder(view: currentColor)
        setBorder(view: firstColor)
        setBorder(view: secondColor)
        setBorder(view: userChoiceColor)
        
        currentColor.backgroundColor = .white
        firstColor.backgroundColor = .red
        secondColor.backgroundColor = .blue
            
        [currentColor, firstColor, secondColor].forEach { drawView in
            drawView?.shapeHitHandler = { [weak self] drawView in
                self?.lastColorChoice?.isShapeHidden = true
                self?.lastColorChoice = drawView
                drawView.moveDrawObject()
                self?.isFirstTap = false
            }
        }
        userChoiceColor.setGestureRecognizers(recognizersArr: [tapColorPicker,longPressColorPicker])
        userChoiceColor = .init()
    }
    
    private func setBorder(view: UIView) {
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBOutlet weak var currentColor: DrawView!
    @IBOutlet weak var firstColor: DrawView!
    @IBOutlet weak var secondColor: DrawView!
    @IBOutlet weak var userChoiceColor: ColorPickerView!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet var tapColorPicker: UITapGestureRecognizer!
    @IBOutlet weak var longPressColorPicker: UILongPressGestureRecognizer!
    
    private func setBorder(field: UIView){
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        dateField.isHidden = !sender.isOn
    }
    
    @IBAction func tapColorPicker(_ sender: UITapGestureRecognizer) {
        if isFirstTap {
            isFirstTap = false
            showSecondViewController(sender)
        }
    }
    
    @IBAction func longPressColorPicker(_ sender: UILongPressGestureRecognizer) {
        showSecondViewController(sender)
    }
    
    func showSecondViewController(_ sender: Any) {
        let secondViewController = SecondViewController()
        secondViewController.colorHandler = { [weak self] (color: UIColor) in
            self?.currColorFromSecView = color
            self?.currentColor.backgroundColor = color
            self?.lastColorChoice?.isShapeHidden = true
            self?.lastColorChoice = self?.currentColor
            self?.currentColor.moveDrawObject()
            if self?.isFirstTap ?? false {
                self?.isFirstTap = false
            }
        }
        secondViewController.currentColor = currColorFromSecView
        present(secondViewController, animated: true, completion: nil)
    }
}
