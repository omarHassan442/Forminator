//
//  ViewController.swift
//  Forminator
//
//  Created by Omar Hassan  on 6/20/18.
//  Copyright © 2018 Omar Hassan. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UsesScrollHandler{
    
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailtxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet var txtFieldList: [UITextField]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var scrollHandlerVar: ScrollHandler? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setScrollHandlerVariable()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        scrollHandlerVar?.RegisterForKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        scrollHandlerVar?.UnRegisterFromKeyboardNotifications()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setScrollHandlerVariable() {
        let first = ScrollHandler.listElement(firstNameTxtField,nil,true)
        let second = ScrollHandler.listElement(lastNameTxtField,nil,true)
        let third = ScrollHandler.listElement(emailtxtField,nil,true)
        let foruth = ScrollHandler.listElement(passwordTxtField,nil,true)
        let fifth = ScrollHandler.listElement(confirmPassword,nil,true)
        
        
        
        let list = [first,second,third,foruth,fifth]
        scrollHandlerVar = ScrollHandler(elementList: list, scrollView: scrollView, contentView: contentView)
    }

}

