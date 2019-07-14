//
//  ViewController.swift
//  Notes
//
//  Created by Sergey on 30/06/2019.
//  Copyright © 2019 Sergey Akentev. All rights reserved.
//

import UIKit

enum colorPicker {
    case whitePicker
    case redPicker
    case greenPicker
    case customPicker
}

class ViewController: UIViewController, UITextViewDelegate {
    
    private var noteTitle: String = ""
    private var noteContent: String = ""
    private var noteColor: UIColor = UIColor.white
    private var noteImportance: Note.Importance = Note.Importance.normal
    private var noteSelfdestructionDate: Date? = nil
    private var note: Note?
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var useDestroyDateSwitch: UISwitch!
    @IBOutlet weak var destroyDatePicker: UIDatePicker!
    @IBOutlet weak var whiteColorPicker: UIColorSelectView!
    @IBOutlet weak var redColorPicker: UIColorSelectView!
    @IBOutlet weak var greenColorPicker: UIColorSelectView!
    @IBOutlet weak var customColorPicker: UIColorSelectView!
    @IBOutlet weak var colorPickerDialogView: UIView!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        colorPickerDialogView.isHidden = true
    }
    
    @IBAction func titleEdited(_ sender: UITextField) {
        noteTitle = titleTextField.text ?? ""
        updateNote()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        noteContent = contentTextView.text
        updateNote()
    }
    
    @IBAction func useDestroyDateChanged(_ sender: UISwitch) {
        destroyDatePicker.isHidden = !useDestroyDateSwitch.isOn
        if useDestroyDateSwitch.isOn {
            noteSelfdestructionDate = destroyDatePicker.date
        } else {
            noteSelfdestructionDate = nil
        }
        updateNote()
    }
    
    @IBAction func destroyDateChanged(_ sender: UIDatePicker) {
        if useDestroyDateSwitch.isOn {
            noteSelfdestructionDate = destroyDatePicker.date
        } else {
            noteSelfdestructionDate = nil
        }
        updateNote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        contentTextView.delegate = self
        
        whiteColorPicker.hitHandler = {[weak self] in self?.colorPicked(.whitePicker)}
        redColorPicker.hitHandler = {[weak self] in self?.colorPicked(.redPicker)}
        greenColorPicker.hitHandler = {[weak self] in self?.colorPicked(.greenPicker)}
        customColorPicker.hitHandler = {[weak self] in self?.colorPicked(.customPicker)}
        
        colorPickerView.colorChangeHandler = {[weak self] in self?.customColorChanged()}
        
    }
    
    func customColorChanged() {
        noteColor = colorPickerView.selectedColor
        customColorPicker.color = noteColor
        customColorPicker.customColorSelected = true
    }
    
    func colorPicked(_ picker: colorPicker) {
        whiteColorPicker.checked = picker == .whitePicker
        redColorPicker.checked = picker == .redPicker
        greenColorPicker.checked = picker == .greenPicker
        customColorPicker.checked = picker == .customPicker
        switch picker {
        case .whitePicker:
            noteColor = UIColor.white
        case .redPicker:
            noteColor = UIColor.red
        case .greenPicker:
            noteColor = UIColor.green
        case .customPicker:
            colorPickerView.selectedColor = noteColor
            customColorPicker.color = noteColor
            customColorPicker.customColorSelected = true
            colorPickerDialogView.isHidden = false
            // Close keyboard
            self.titleTextField.resignFirstResponder()
            self.contentTextView.resignFirstResponder()
        }
        if picker != .customPicker {
            customColorPicker.customColorSelected = false
        }
        updateNote()
    }
    
    func updateNote() {
        note = Note(title: noteTitle, content: noteContent, importance: noteImportance, color: noteColor, selfDestructionDate: noteSelfdestructionDate)
    }
    
}

// Extension for "done" panel, cause sometimes you need to just close keyboard and edit colors/destroy date
extension UITextField {
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

extension UITextView {
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}
