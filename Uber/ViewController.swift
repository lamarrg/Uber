//
//  ViewController.swift
//  Uber
//
//  Created by Lamar Greene on 2/4/16.
//  Copyright © 2016 Lamar Greene. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBAction func signup(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
        
            let alert = UIAlertController(title: "Missing Fields", message: "username and password required", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(alertAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }

    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var toggleSignupButton: UIButton!
    
    @IBAction func toggleSignup(sender: AnyObject) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

