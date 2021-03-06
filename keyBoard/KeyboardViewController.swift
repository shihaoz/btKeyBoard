//
//  KeyboardViewController.swift
//  keyBoard
//
//  Created by Shihao Zhang on 11/7/16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import UIKit
import Dispatch
class KeyboardViewController: UIInputViewController {
    /**
     
     */
    private struct keyBoardLayOut{
        static let spaceBetweenRow = CGFloat(5)   // vertical space between different row
        static var rowHeight = CGFloat(30)         // height of a row
        static let rowSpacing = CGFloat(5)         // spacing within a row
        static var buttonWidth = CGFloat(30)    // need to be recalculated
        
        static let firstRowRatios: Array<Float> = [
            0.2, 0.2, 0.4, 0.2
        ]
        
        static let screenKeyBoardRatioLandscape = 2.2   // @heuristic-value for iphone6s/7
        static let screenKeyBoardRatioPortrait = 2.8    // @heuristic-value for iphone6s/7
    }
    
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
        
        // load nib UI
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
            let button = secondRow[idx]
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
        layoutGrid.append(completeRow)
        
        for row in layoutGrid{  // round corner
            for button in row!{
                button.layer.cornerRadius = 5
                button.layer.shadowColor = UIColor.gray.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
                button.layer.shadowOpacity = 1.0;
                button.layer.shadowRadius = 0.0;
            }
        }
        /**
         @performance: optimize below
        */
        initLayout(screenKeyboardRatio: keyBoardLayOut.screenKeyBoardRatioPortrait)    // set size and layout
        _updateSelect(target: currentXY)    // update selection
        readFile()                          // load word file
        suggestion.buildTree(words: dictionary) // build prediction tree
        
        // initialize bluetooth
        btManager = BTDiscovery(kbControl: self)

    }
    /**
     detect rotation, redraw layout
    */
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if fromInterfaceOrientation.isLandscape{    // landscape --> portrait
            initLayout(screenKeyboardRatio: keyBoardLayOut.screenKeyBoardRatioPortrait )
            
            backSpaceKey.setBackgroundImage( UIImage(named: "backspacePortrait"), for: .normal)
            if isUpper {
                caseKey.setBackgroundImage( UIImage(named: "UpperCasePortrait") , for: .normal)
            }
            else{
                caseKey.setBackgroundImage( UIImage(named: "LowerCasePortrait") , for: .normal)
            }
        }
        else{                                       // portrait --> landscape
            initLayout(screenKeyboardRatio: keyBoardLayOut.screenKeyBoardRatioLandscape )
            
            backSpaceKey.setBackgroundImage( UIImage(named: "backspaceLandScape"), for: .normal)
            if isUpper {
                caseKey.setBackgroundImage( UIImage(named: "UpperCaseLandScape") , for: .normal)
            }
            else{
                caseKey.setBackgroundImage( UIImage(named: "LowerCaseLandScape") , for: .normal)
            }
        }
        isPortrait = !isPortrait
    }

    /**
     initialize the layout for keyboard
     including:
     1. setting size, 
     2. embed in stack view
     2. define leading/trailing spaces
    */
    @objc private func initLayout(screenKeyboardRatio: Double){
        
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height/CGFloat(screenKeyboardRatio)   // @fix:

        print(screenWidth, screenHeight)
        keyBoardLayOut.buttonWidth = (screenWidth - 9*keyBoardLayOut.rowSpacing)/10
        
        // set row height
        keyBoardLayOut.rowHeight = (screenHeight - CGFloat(layoutGrid.count-1)*keyBoardLayOut.rowSpacing)/CGFloat(layoutGrid.count)
        print("rowHeight: \(keyBoardLayOut.rowHeight)")
        
        var x = CGFloat(0), y = CGFloat(5)
        
        completeRowStack.frame = CGRect(x: x, y: y, width: screenWidth-2*x, height: keyBoardLayOut.rowHeight)
        completeRowStack.alignment = UIStackViewAlignment.fill
        completeRowStack.distribution = UIStackViewDistribution.fillEqually
        completeRowStack.spacing = keyBoardLayOut.rowSpacing
        
        
        x = getLeadingTrailingSpace(numberElement: 10)
        y += keyBoardLayOut.rowHeight + keyBoardLayOut.spaceBetweenRow
        
        forthRowStack = UIStackView(frame: CGRect(x: x, y: y, width: screenWidth-2*x, height: keyBoardLayOut.rowHeight ))
        for button in forthRow{
            forthRowStack?.addArrangedSubview(button)
        }
        forthRowStack!.alignment = UIStackViewAlignment.fill
        forthRowStack!.distribution = UIStackViewDistribution.fillEqually
        forthRowStack!.spacing = 5
        view.addSubview(forthRowStack!)
        
        x = getLeadingTrailingSpace(numberElement: thirdRow.count)
        y += keyBoardLayOut.rowHeight + keyBoardLayOut.spaceBetweenRow
        
        thirdRowStack = UIStackView(frame: CGRect(x: x, y: y, width: screenWidth-2*x, height: keyBoardLayOut.rowHeight))
        for button in thirdRow{
            thirdRowStack?.addArrangedSubview(button)
        }
        thirdRowStack!.alignment = UIStackViewAlignment.fill
        thirdRowStack!.distribution = UIStackViewDistribution.fillEqually
        thirdRowStack!.spacing = 5
        view.addSubview(thirdRowStack!)
        
        x = getLeadingTrailingSpace(numberElement: secondRow.count)
        y += keyBoardLayOut.rowHeight + keyBoardLayOut.spaceBetweenRow
        
        secondRowStack = UIStackView(frame: CGRect(x: x, y: y, width: screenWidth-2*x, height: keyBoardLayOut.rowHeight))
        for button in secondRow{
            secondRowStack?.addArrangedSubview(button)
        }
        secondRowStack!.alignment = UIStackViewAlignment.fill
        secondRowStack!.distribution = UIStackViewDistribution.fillEqually
        secondRowStack!.spacing = 5
        view.addSubview(secondRowStack!)
        
        x = CGFloat(0)
        y += keyBoardLayOut.rowHeight + keyBoardLayOut.spaceBetweenRow
        
        
        var widthArray: Array<CGFloat> = []
        for w in keyBoardLayOut.firstRowRatios{
            widthArray.append(CGFloat(
                Float(screenWidth - keyBoardLayOut.rowSpacing * CGFloat(keyBoardLayOut.firstRowRatios.count)) * w))
        }
        setButtonsSize(x: x, y: y, width: widthArray, height: keyBoardLayOut.rowHeight, row: firstRow)
    }
    
/*  =========>> private variables <<=========  */
    
    enum Movement {
        /// defines a movement signal from Bluetooth
        case Left
        case Right
        case Up
        case Down
        case Click
        case BackSpace
    }
    
    private var keyboardView: UIView!
    private var currentXY: (x: Int, y: Int) = (x: 2, y: 5)  // start with 'H'
    private var isUpper = true  // if uppercase character is shown
    private var layoutGrid = Array<Array<UIButton>?>()
    private var suggestion = prefixTree()
    private var dictionary: Array<String> = []
    private var isPortrait = true
    private var btManager: BTDiscovery?
    
    var forthRowStack: UIStackView? = nil
    var thirdRowStack: UIStackView? = nil
    var secondRowStack: UIStackView? = nil
    var firstRowStack: UIStackView? = nil
    
/*  =========>> IB Outlet <<=========  */
    
    
    /// symbol, next, space, return
    var firstRow: Array<UIButton> = Array<UIButton>()   // symbol->number, next, space, return
    /// suggested word row
    @IBOutlet weak var completeRowStack: UIStackView!
    
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
        _textChange()
        selectButton(button: sender)
    }
    
    /**
     insert suggested word
    */
    @IBAction func suggestPressed(sender: UIButton!){
        let suggestWord = sender.currentTitle
        var inputText = textDocumentProxy.documentContextBeforeInput
        if suggestWord != nil && inputText != nil{
            // remove latest word
            var idx = inputText!.characters.count-1
            while idx >= 0 && inputText?[(inputText?.index((inputText?.startIndex)!, offsetBy: idx))!] != " " {
                idx -= 1
                textDocumentProxy.deleteBackward()
            }
            textDocumentProxy.insertText(suggestWord! + " ")
        }
        selectButton(button: sender)
    }
    /**
     backspace is pressed
    */
    @IBAction func backSpacePress(sender: UIButton!){
        textDocumentProxy.deleteBackward()
        _textChange()
        selectButton(button: sender)
    }
    
    /**
     return is pressed
     */
    @IBAction func returnPressed(sender: UIButton!){
        textDocumentProxy.insertText("\n")
        selectButton(button: sender)
    }
    /**
     case key is pressed
     flip the _isUpper, and convert case
    */
    @IBAction func caseKeyPressed(sender: UIButton!){
        /// convert image
        var image: UIImage = sender.backgroundImage(for: .normal)!
        let postFix: String = isPortrait ? "Portrait" : "LandScape"
        if isUpper{
            image = UIImage(named: "LowerCase\(postFix)")!
        }
        else{
            image = UIImage(named: "UpperCase\(postFix)")!
        }
        sender.setBackgroundImage(image, for: UIControlState.normal)
        isUpper = !isUpper
        convertCase(toUpper: isUpper)
        selectButton(button: sender)
    }
    @IBAction func donothing(sender: UIButton!){
        // do nothing
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
    func btSignal(move: Movement){
        _move(direction: move)
    }
/*  =========>> Utility Function <<=========  */
    
    private func setButtonsSize(x: CGFloat, y: CGFloat, width: Array<CGFloat>, height: CGFloat, row: Array<UIButton>){
        if width.count != row.count {
            print("error: width-count \(width.count) doesn't match row-count \(row.count)")
        }
        else{
            var idx = 0
            var startX = x
            for button in row{
                button.frame = CGRect(x: startX, y: y, width: width[idx], height: height)
                startX += width[idx] + keyBoardLayOut.rowSpacing
                idx += 1
            }
        }
    }
    
    /**
     @input: number of elements on a row
     @effect:
        get leading/trailing space
    */
    private func getLeadingTrailingSpace(numberElement: Int) -> CGFloat{
        return (UIScreen.main.bounds.width
            - (CGFloat(numberElement) * keyBoardLayOut.buttonWidth)
            - (CGFloat((numberElement-1)) * keyBoardLayOut.rowSpacing))/2
    }
    
    /**
     set selection box for this button
    */
    func selectButton(button: UIButton!) -> Void {
        for row in 0..<layoutGrid.count{
            for idx in 0..<layoutGrid[row]!.count{
                if layoutGrid[row]?[idx] == button{
                    _updateSelect(target: (row, idx))
                    break
                }
            }
        }
    }
    /**
     when a symbolic key(non-operation key) is pressed
     
     @effect:
     insert button text to input
     */
    @objc private func keyPressed(sender: UIButton!){
        textDocumentProxy.insertText(sender.currentTitle!)
        _textChange()
        selectButton(button: sender)
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
                let button = secondRow[idx]
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
                let button = secondRow[idx]
                button.setTitle(button.currentTitle!.lowercased(), for: UIControlState.normal)
            }
        }

    }
    
    
    /**
     @input: 
        direction: a movement enum
     @effect:
        move the selection box accordingly
 
    */
    private func _move(direction: Movement){
        var targetXY = currentXY
        let senderButton = layoutGrid[currentXY.x]?[currentXY.y]
        
        switch direction {
            /**
            x controls up/down, y controls left/right
             because we index like [xRow][yColumn]
                */
            case .Left:
                targetXY.y -= 1
            case .Right:
                targetXY.y += 1
            case .Up:
                if targetXY.x == 0 {// special mapping for first->secondRow
                    switch targetXY.y {
                    case 2: // (0,2) --> (1,4) space --> V
                        targetXY.y = 4
                    case 3: // (0,3) --> (1,8) return --> backspace
                        targetXY.y = 8
                    default:
                        break
                    }
                }
                else if targetXY.x == 3 {   // special mapping for forth->completeRow
                    switch targetXY.y{
                    case 0...3: // (q,w,e,r) --> 1st suggested word
                        targetXY.y = 0
                    case 4...6: // (t,y,u) --> 2nd suggested word
                        targetXY.y = 1
                    case 7...9: // (i,o,p) --> 3rd suggested word
                        targetXY.y = 2
                    default:
                        break
                    }
                }
                targetXY.x += 1
            case .Down:
                if targetXY.x == 1{// special mapping for second->firstRow
                    switch targetXY.y {
                    case 8: // backspace --> return
                        targetXY.y = 3
                    case 2: // x --> Next
                        targetXY.y = 1
                    case 3...7: // c,v,b,n,m --> space
                        targetXY.y = 2
                    default:
                        break
                    }
                }
                else if(targetXY.x == 4){ // special mapping for complete->forthRow
                    switch  targetXY.y {
                    case 0:
                        targetXY.y = 0
                    case 1:
                        targetXY.y = 4
                    case 2:
                        targetXY.y = 7
                    default:
                        break
                    }
                }
                targetXY.x -= 1
            
        case .Click:    // a click event
            DispatchQueue.global(qos: .userInitiated).async {
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    senderButton?.sendActions(for: .touchUpInside)
                }
            }
            
        case .BackSpace:    // backspace event
            backSpacePress(sender: senderButton)
            
        }
        if  (targetXY.x < 0 || targetXY.x >= layoutGrid.count) {  // if out of bound
            // stays the same, Do-not-wrap

        }
        else{
            // contain left or right operation
            if targetXY.y < 0 {
                targetXY.y = 0
            }
            if targetXY.y >= (layoutGrid[targetXY.x]?.count)!{
                targetXY.y = (layoutGrid[targetXY.x]?.count)! - 1
            }
            // remove the selection on last one
            DispatchQueue.global(qos: .userInitiated).async {
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    self.layoutGrid[self.currentXY.x]![self.currentXY.y].layer.borderWidth = 0.0
                    self.layoutGrid[targetXY.x]![targetXY.y].layer.borderWidth = 2.0
                    self.layoutGrid[targetXY.x]![targetXY.y].layer.borderColor = UIColor.blue.cgColor
                    self.currentXY = targetXY
                }
            }
        }
        
        
    }
    

    
    /**
     @input: new valid coordinate
     @effect:
        1. show selection on new coordinate,
        2. invalidate selection on old coordinate
        3. update currentXY
    */
    private func _updateSelect(target: (Int, Int)){
        layoutGrid[currentXY.x]![currentXY.y].layer.borderWidth = 0.0
        currentXY = target
        layoutGrid[currentXY.x]![currentXY.y].layer.borderWidth = 2.0
        layoutGrid[currentXY.x]![currentXY.y].layer.borderColor = UIColor.blue.cgColor
    }
    
    /**
     @effect:
        call when user input changes
        update suggested words
     */
    private func _textChange(){
        var list: Array<String> = []
        if textDocumentProxy.documentContextBeforeInput != nil{
            var targetWord = textDocumentProxy.documentContextBeforeInput! + (textDocumentProxy.documentContextAfterInput ?? "")
            /**
             when user input looks like "abc  abd   ", ends in a whitespace, that means no completion is needed
             otherwise complete on the last word --> e.g. "abc abd" will complete on abd,
                                                    "ab" will complete on ab
             */
            if targetWord.isEmpty || targetWord.characters.last == " " {
                // dont do shit
            }
            else{
                targetWord = targetWord.components(separatedBy: " ").last!   // complete on last word
                list = suggestion.getSuggestion(target: targetWord)
            }
        }
        print("recommendation: \(list)")
        DispatchQueue.global(qos: .userInitiated).async {
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                for i in 0..<list.count{
                    self.completeRow[i].setTitle(list[i], for: UIControlState.normal)
                }
                for i in list.count..<self.completeRow.count{
                    self.completeRow[i].setTitle(" ", for: UIControlState.normal)
                }
            }
        }
    }
    
    /**
     read word list from file
    */
    private func readFile(){
        if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                dictionary = data.components(separatedBy: .newlines)
            } catch {
                print(error)
            }
        }
    }
    
}
