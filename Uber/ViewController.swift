//
//  ViewController.swift
//  Uber
//
//  Created by Lamar Greene on 2/4/16.
//  Copyright © 2016 Lamar Greene. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    func displayAlert(title: String, message: String){
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(alertAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    var signupState = true
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var userStatus: UISwitch!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBAction func signup(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
        
            displayAlert("Missing Field(s)", message: "Username and password are required")
            
        } else {
        
            
            if signupState == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
            
                user["isDriver"] = userStatus.on
                user.signUpInBackgroundWithBlock({ (succeeded, error) -> Void in
                    
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? String {
                            
                            // show errorstring and let user try again
                            
                            self.displayAlert("Sign Up Failed", message: errorString)
                            
                        }
                        
                    } else {
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        
                    }
                    
                })
            
            } else {
            
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user: PFUser?, error: NSError?) -> Void in
                    
                    if user != nil {
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        
                    
                    } else {
                    
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            // show errorstring and let user try again
                            
                            self.displayAlert("Login Failed", message: errorString)
                            
                        }
                    
                    
                    }
                    
                })
            
            
            }
            
        }
        
    }

    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var toggleSignupButton: UIButton!
    
    @IBAction func toggleSignup(sender: AnyObject) {
        
        if signupState == true {
        
            signupButton.setTitle("Login", forState: .Normal)
            
            toggleSignupButton.setTitle("Switch to signup", forState: .Normal)
            
            signupState = false
            
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            userStatus.alpha = 0
        
        } else {
            
            signupButton.setTitle("Signup", forState: .Normal)
            
            toggleSignupButton.setTitle("Switch to login", forState: .Normal)
            
            signupState = true
            
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            userStatus.alpha = 1
            
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self
        self.password.delegate = self
        
    }
    
    func DismissKeyboard() {
    
        view.endEditing(true)
    
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil  {
        
            self.performSegueWithIdentifier("loginRider", sender: self)
            
        }
        
    }



}

