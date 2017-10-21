//
//  SurveyActionViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/15/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class SurveyActionViewController: UIViewController {
    public static let DEMO = "DEMO";
//    private MyAlarmManager myAlarmManager;
    private static let isDemo = true;
    private var settings :Settings!
    public var requestCode : Int!;
    public var surveyCode : Int!;
    private var timeTag : String!;


    @IBOutlet weak var requestCodeLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        print("in SurveyAction the request code is", requestCode)
        requestCodeLable.text = String(requestCode)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SurveyStart(_ sender: Any) {
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
