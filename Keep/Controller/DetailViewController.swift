//
//  DetailViewController.swift
//  Keep
//
//  Created by Obi-Voin Kenobi on 12/19/17.
//  Copyright © 2017 Obi-Voin Kenobi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var actionsToolbar: UIToolbar!
    @IBOutlet var actionsToolbarForKeyboard: UIToolbar!
    
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    
    public var isNewNote: Bool = true
    public var selectedNote: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Accessory View to Keyboard for TextField & TextView
        titleTextField.inputAccessoryView = actionsToolbarForKeyboard
        noteTextView.inputAccessoryView = actionsToolbarForKeyboard
        
        // Set up Delegate for TextField & TextView
        titleTextField.delegate = self
        noteTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isNewNote {
            if let note = selectedNote {
                titleTextField.text = note.title
                noteTextView.text = note.note
                noteTextView.textColor = .black
                
                navigationItem.title = note.title ?? "Untitle"
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            willSaveOrUpdateNote()
        }
    }
    
    
    
    func willSaveOrUpdateNote() {
        let titleString = titleTextField.text?.trimmingCharacters(in: .whitespaces) == "" ? nil : titleTextField.text
        let noteString = !(noteTextView.textColor!.isEqual(UIColor.black)) ? nil : noteTextView.text
        
        if titleString == nil && noteString == nil { return }
        
        if isNewNote {
            let note = Note(id: nil, title: titleString, note: noteString)
            
            if CoreDataCRUD.shared.insert(noteValue: note) {
                print("Note Saved")
            }
        }
        else {
            let note = Note(id: selectedNote.id, title: titleString, note: noteString)
            
            if CoreDataCRUD.shared.update(updateNote: note) {
                print("Note Updated")
            }
        }
        
    }
    
    @IBAction func didTouchAddBarButton(_ sender: UIBarButtonItem) {
        let addActions = ["Take photo", "Choose image", "Drawing", "Recording", "Checkboxes "]
        showActionSheetAlert(actionTitles: addActions)
    }
    
    @IBAction func didTouchMoreBarButton(_ sender: UIBarButtonItem) {
        let moreActions = ["Delete", "Make a copy", "Send", "Collaborators", "Labels"]
        showActionSheetAlert(actionTitles: moreActions)
    }
    
    public func showActionSheetAlert(actionTitles: [String]) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for title in actionTitles {
            actionSheet.addAction(UIAlertAction(title: title, style: .default, handler: nil))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noteTextView.becomeFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == "Note") {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            textView.text = "Note"
            textView.textColor = .lightGray
        }
    }
    
    @objc func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // Update Bottom Space Constraint of noteTextView
        textViewBottomSpaceConstraint.constant = keyboardFrame.height - actionsToolbar.bounds.height
    }
    
}
