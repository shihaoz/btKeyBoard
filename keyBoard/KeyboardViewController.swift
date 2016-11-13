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
    
        // add press event
        for button in forthRow{
            button.addTarget(self, action: #selector(self.keyPressed(sender:)), for: .touchUpInside)
        }
        // add press event
        for button in thirdRow{
            button.addTarget(self, action: #selector(self.keyPressed(sender:)), for: .touchUpInside)
        }
        // add press event, but not for caseKey [0] and backSpace [-1]
        for idx in 1..<secondRow.count-1{
            var button = secondRow[idx]
            button.addTarget(self, action: #selector(self.keyPressed(sender:)), for: .touchUpInside)
        }
        
        // store firstRow
        firstRow.append(numberKey)
        firstRow.append(nextKeyboardButton)
        firstRow.append(spaceKey)
        firstRow.append(returnKey)
        
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
        
        _updateSelect()
        readFile()
        suggestion.buildTree(words: dictionary)
    }
    
    
/*  =========>> private variables <<=========  */
    private var keyboardView: UIView!
    private var currentXY: (x: Int, y: Int) = (x: 2, y: 5)  // start with 'H'
    private var isUpper = true  // if uppercase character is shown
    private var layoutGrid = Array<Array<UIButton>?>()
    private var suggestion = prefixTree()
    

/*  =========>> IB Outlet <<=========  */
    
    
    /// symbol, next, space, return
    var firstRow: Array<UIButton> = Array<UIButton>()   // symbol->number, next, space, return
    
    /// case, [z->m], backspace
    @IBOutlet var secondRow: Array<UIButton> = Array<UIButton>()
    
    /// [a-l]
    @IBOutlet var thirdRow: Array<UIButton> = Array<UIButton>()
    
    /// [q->P]
    @IBOutlet var forthRow: Array<UIButton> = Array<UIButton>()
    
    /// the suggested words
    @IBOutlet var completeRow: Array<UIButton> = Array<UIButton>()
    
    @IBOutlet weak var numberKey: UIButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var spaceKey: UIButton!
    @IBOutlet weak var returnKey: UIButton!
    @IBOutlet weak var caseKey: UIButton!
    @IBOutlet weak var backSpaceKey: UIButton!
/*  =========>> IB Actions <<=========  */
    
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
        _textChange()
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
        // flip the boolean, and convert case
        isUpper = !isUpper
        convertCase(toUpper: isUpper)
    }
    
    
    /** mocking bluetooth signal */
    @IBAction func btMove(sender: UIButton!){
        switch sender.currentTitle! {
            case "Left":
                _move(direction: .Left)
            case "Right":
                _move(direction: .Right)
            case "Up":
                _move(direction: .Up)
            case "Down":
                _move(direction: .Down)
            default:
                break
        }
    }
    
/*  =========>> Utility Function <<=========  */
    /**
     when a symbolic key(non-operation key) is pressed
     
     @effect:
     insert button text to input
     */
    @objc private func keyPressed(sender: UIButton!){
        textDocumentProxy.insertText(sender.currentTitle!)
        _textChange()
    }
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
    private func convertCase(toUpper: Bool){
        if toUpper{
            for button in forthRow{
                button.setTitle(button.currentTitle!.uppercased(), for: UIControlState.normal)
            }
            for button in thirdRow{
                button.setTitle(button.currentTitle!.uppercased(), for: UIControlState.normal)
            }
            for idx in 1..<secondRow.count-1{
                var button = secondRow[idx]
                button.setTitle(button.currentTitle!.uppercased(), for: UIControlState.normal)
            }
        }
        else{
            for button in forthRow{
                button.setTitle(button.currentTitle!.lowercased(), for: UIControlState.normal)
            }
            for button in thirdRow{
                button.setTitle(button.currentTitle!.lowercased(), for: UIControlState.normal)
            }
            for idx in 1..<secondRow.count-1{
                var button = secondRow[idx]
                button.setTitle(button.currentTitle!.lowercased(), for: UIControlState.normal)
            }
        }

    }
    enum Movement {
        case Left
        case Right
        case Up
        case Down
    }
    private func _move(direction: Movement){
        var lastXY = currentXY
        switch direction {
            /**
            x controls up/down, y controls left/right
             because we index like [xRow][yColumn]
                */
            case .Left:
                currentXY.y -= 1
            case .Right:
                currentXY.y += 1
            case .Up:
                if currentXY.x == 0 {// special mapping
                    switch currentXY.y {
                    case 2: // (0,2) --> (1,4) space --> V
                        currentXY.y = 4
                    case 3: // (0,3) --> (1,8) return --> backspace
                        currentXY.y = 8
                    default:
                        break
                    }
                }
                currentXY.x += 1
            case .Down:
                if currentXY.x == 1{// special mapping
                    switch currentXY.y {
                    case 8: // backspace --> return
                        currentXY.y = 3
                    case 2: // x --> Next
                        currentXY.y = 1
                    case 3...7: // c,v,b,n,m --> space
                        currentXY.y = 2
                    default:
                        break
                    }
                }
                currentXY.x -= 1
            default:
                break
        }
        if  (currentXY.x < 0 || currentXY.x >= 4) {  // if out of bound
            // stays the same, Do-not-wrap
            currentXY = lastXY
        }
        else{
            // contain left or right operation
            if currentXY.y < 0 {
                currentXY.y = 0
            }
            if currentXY.y >= (layoutGrid[currentXY.x]?.count)!{
                currentXY.y = (layoutGrid[currentXY.x]?.count)! - 1
            }
            // remove the selection on last one
            let targetButton: UIButton = layoutGrid[lastXY.x]![lastXY.y]
            targetButton.layer.borderWidth = 0.0
        }

        _updateSelect()
    }
    private func _updateSelect(){
        let targetButton: UIButton = layoutGrid[currentXY.x]![currentXY.y]
        targetButton.layer.borderWidth = 2.0
        targetButton.layer.borderColor = UIColor.blue.cgColor
    }
    private func _textChange(){
        var list: Array<String> = []
        if textDocumentProxy.documentContextBeforeInput != nil{
            list = suggestion.getSuggestion(target: textDocumentProxy.documentContextBeforeInput! + (textDocumentProxy.documentContextAfterInput ?? ""))
        }
        print(list)
        for i in 0..<list.count{
            completeRow[i].setTitle(list[i], for: UIControlState.normal)
        }
        for i in list.count..<completeRow.count{
            completeRow[i].setTitle(" ", for: UIControlState.normal)
        }
    }
    
    func readFile(){
        if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                dictionary = data.components(separatedBy: .newlines)
            } catch {
                print(error)
            }
        }
    }
    private var dictionary: Array<String> = []
}
