//
//  admainViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class admainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let settings = Settings()
    let defaults = UserDefaults.standard
    var surveys = [String]()

    @IBOutlet weak var rtidContent: UILabel!
    @IBOutlet weak var dateContent: UILabel!
    @IBOutlet weak var beginContent: UILabel!
    @IBOutlet weak var endContent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        if( defaults.object(forKey: Constants.rtidKey) != nil){
            rtidContent.text = ": " + defaults.string(forKey: Constants.rtidKey)!
            dateContent.text = ": " + defaults.string(forKey: Constants.setAtTimeKey)!
            beginContent.text = ": " + defaults.string(forKey: Constants.beginTimeKey)!
            endContent.text = ": " + defaults.string(forKey: Constants.endTimeKey)!
            surveys = (defaults.string(forKey: Constants.surveysKey)?.components(separatedBy: "\n"))!
        }
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarm", for: indexPath) as! alarmTableViewCell
        cell.alarmDetail.text = surveys[indexPath.row]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
