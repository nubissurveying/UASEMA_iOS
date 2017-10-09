//
//  recordViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class recordViewController: UIViewController {

    @IBOutlet weak var mcImage: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        mcImage.backgroundColor = .clear
        mcImage.layer.cornerRadius = 5
        mcImage.layer.borderWidth = 1
        mcImage.layer.borderColor = UIColor.black.cgColor
        
        SaveButton.backgroundColor = .clear
        SaveButton.layer.cornerRadius = 5
        SaveButton.layer.borderWidth = 1
        SaveButton.layer.borderColor = UIColor.black.cgColor
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func MicActon(_ sender: Any) {
    }
    
    @IBAction func SaveUpload(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
