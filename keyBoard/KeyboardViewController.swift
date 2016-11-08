//
//  KeyboardViewController.swift
//  keyBoard
//
//  Created by Shihao Zhang on 11/7/16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {


    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        /// load UI
        loadInterface()
    
        // store into layoutGrid (coordinate system)
        layoutGrid.append(firstRow)
        layoutGrid.append(secondRow)
        layoutGrid.append(thirdRow)
        layoutGrid.append(forthRow)
        for row in layoutGrid{  // round corner
            for button in row!{
                button.layer.cornerRadius = 5
                button.layer.shadowColor = UIColor.gray.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
                button.layer.shadowOpacity = 1.0;
                button.layer.shadowRadius = 0.0;
            }
        }
        
    }
    
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
/*  =========>> private variables <<=========  */
    private var keyboardView: UIView!
    private var currentXY: (Int, Int) = (2, 6)  // start with 'H'

    private var layoutGrid = Array<Array<UIButton>?>()
    
    
/*  =========>> IB Outlet <<=========  */
    @IBOutlet var nextKeyboardButton: UIButton!
    
    /// symbol, next, space, return
    @IBOutlet var firstRow: Array<UIButton> = Array<UIButton>()   // symbol->number, next, space, return
    
    /// case, [z->m], backspace
    @IBOutlet var secondRow: Array<UIButton> = Array<UIButton>()
    
    /// [a-l]
    @IBOutlet var thirdRow: Array<UIButton> = Array<UIButton>()
    
    /// [q->P]
    @IBOutlet var forthRow: Array<UIButton> = Array<UIButton>()
    
    /// the suggested words
    @IBOutlet var completeRow: Array<UIButton> = Array<UIButton>()
    
/*  =========>> IB Actions <<=========  */
    
    /**
     when a symbolic key(non-operation key) is pressed
     
     @effect:
        insert button text to input
     */
    @IBAction func keyPressed(sender: UIButton!){
        textDocumentProxy.insertText(sender.currentTitle!)
    }
    
    /**
     space is pressed
    */
    @IBAction func spacePressed(sender: UIButton!){
        textDocumentProxy.insertText(" ")
    }
    
    /**
     backspace is pressed
    */
    @IBAction func backSpacePress(sender: UIButton!){
        textDocumentProxy.deleteBackward()
    }
    
    /**
     return is pressed
     */
    @IBAction func returnPressed(sender: UIButton!){
        textDocumentProxy.insertText("\n")
    }
    /**
     case key is pressed
    */
    @IBAction func caseKeyPressed(sender: UIButton!){
        
    }
/*  =========>> Utility Function <<=========  */
    /**
     load the view
     
     @effect:
     1. load Nib File as view
     2. set nextKeyBoardButton
     3. setup coordinate system
     */
    func loadInterface() {
        // load the nib file
        let calculatorNib = UINib(nibName: "keyBoard", bundle: nil)
        // instantiate the view
        keyboardView = calculatorNib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // add the interface to the main view
        view.addSubview(keyboardView)
        
        // copy the background color
        view.backgroundColor = keyboardView.backgroundColor
        
        // addNextButton --- must specify so you can switch between different keyboards
        nextKeyboardButton.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
    }
    /**
     convert symbolic keys to lowercase/uppercase
    */
    private func _convertCase(toUpper: Bool){
        if toUpper{
            for button in firstRow{
                button.setTitle(button.currentTitle!.uppercased(), for: UIControlState.normal)
            }
        }
        else{
            for button in firstRow{
                button.setTitle(button.currentTitle!.lowercased(), for: UIControlState.normal)
            }
        }

    }
    
    private func _updateSelect(){
        layoutGrid[currentXY.]
    }
}
