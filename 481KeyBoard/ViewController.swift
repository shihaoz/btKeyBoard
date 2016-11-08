//
//  ViewController.swift
//  481KeyBoard
//
//  Created by Shihao Zhang on 11/7/16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var textField = UITextField(frame: CGRect(x: 5, y: 5, width: 300, height: 300) )
        textField.text = "Hello World"
        textField.textAlignment = NSTextAlignment.center
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.lightGray
        self.view.addSubview(textField)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

