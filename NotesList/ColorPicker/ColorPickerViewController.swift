//
//  ViewController.swift
//  test
//
//  Created by ios_school on 1/30/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    var note: Note?
    var newNote: Note? = nil
    var currColorFromSecView: UIColor = .gray
    var lastColorChoice: DrawView?
    var addNewNote: ((Note) -> Void)?
    var deleteOldNote: ((Note) -> Void)?
    @IBOutlet weak var userChoiceColor: ColorPickerView!
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if let title = titleField.text, let content = contentField.text, let importance = note?.impotance {
            newNote = Note(uid: note?.uid, title: title, content: content, color: lastColorChoice?.backgroundColor, impotance: importance, selfDestructionDate: dateField.date)
            if let oldNote = self.note {
                deleteOldNote?(oldNote)
            }
            if let newNote = self.newNote {
                addNewNote?(newNote)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentField: UITextView!
    
    private var isFirstTap = true {
        didSet {
            tapColorPicker.isEnabled = false
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = false
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
        lastColorChoice = currentColor
        currentColor.moveDrawObject()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleField.text = note?.title
        contentField.text = note?.content
        if let selfDestructionDate = note?.selfDestructionDate {
            dateField.date = selfDestructionDate
        } else {
            dateSwitch.isOn = false
            dateField.isHidden = true
        }
        currentColor.backgroundColor = note?.color
        lastColorChoice = currentColor
        currentColor.moveDrawObject()
       // navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setBorder(view: UIView) {
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBOutlet weak var currentColor: DrawView!
    @IBOutlet weak var firstColor: DrawView!
    @IBOutlet weak var secondColor: DrawView!
    
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet var tapColorPicker: UITapGestureRecognizer!
    @IBOutlet weak var longPressColorPicker: UILongPressGestureRecognizer!
    @IBOutlet weak var dateSwitch: UISwitch!
    
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
