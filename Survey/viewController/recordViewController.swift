//
//  recordViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import AVFoundation
import EasyToast
import Alamofire

class recordViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var mcImage: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    let recordName = "recording.m4a"
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
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("audio allowed")
                    } else {
                        print("audio denied")
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func MicActon(_ sender: Any) {
        if(isRecording){
            mcImage.setImage(UIImage(named: "microphone_check"), for: UIControlState.normal)
            isRecording = false;
            self.finishRecording(success: true)
        } else {
            mcImage.setImage(UIImage(named: "microphone_recording"),for: UIControlState.normal)
            isRecording = true;
            self.startRecording()
        }
    }
    func startRecording() {
        print("start recording")
        self.view.showToast("start recording", position: .bottom, popTime: 2, dismissOnTap: false)
        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            
        } catch {
            finishRecording(success: false)
            
        }
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            mcImage.setImage(UIImage(named: "microphone_check"), for: UIControlState.normal)
            print("record succeed")
            self.view.showToast("record succeed", position: .bottom, popTime: 2, dismissOnTap: false)
        } else {
            mcImage.setImage(UIImage(named: "microphone"),for: UIControlState.normal)
            self.view.showToast("record fail", position: .bottom, popTime: 2, dismissOnTap: false)
            print("record fail")
            // recording failed :(
        }
    }
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func removeFileAt(url: URL){
        do{
            try FileManager.default.removeItem(at: url)
            
        }catch let error as NSError {
            print("delete fail: \(error)")
        }
    }
    
    @IBAction func SaveUpload(_ sender: Any) {
        mcImage.setImage(UIImage(named: "microphone"),for: UIControlState.normal)
        isRecording = false;
        playAudio()
        uploadAudio(url: getDocumentsDirectory().appendingPathComponent(recordName))
        
    }
    func uploadAudio(url : URL){
        self.mcImage.isEnabled  = false
        self.SaveButton.isEnabled = false
        
        var now = Date()
        let soundrecorded = FileManager.default.fileExists(atPath: url.path)
        if(soundrecorded){
            self.view.showToast("uploading", position: .bottom, popTime: 3, dismissOnTap: false)
            removeFileAt(url: url)
        } else {
            self.view.showToast("nothing to upload", position: .bottom, popTime: 3, dismissOnTap: false)
        }
        
        
        self.mcImage.isEnabled  = true
        self.SaveButton.isEnabled = true
    }
    
    func playAudio(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordName)
        if(!FileManager.default.fileExists(atPath: audioFilename.path)){
            self.view.showToast("nothing to play", position: .bottom, popTime: 3, dismissOnTap: false)
            return 
        }
        
        
        do {
            print("audio play")
            self.view.showToast("audio play", position: .bottom, popTime: 3, dismissOnTap: true)
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
            self.view.showToast("audioPlayer error \(error.localizedDescription)", position: .bottom, popTime: 3, dismissOnTap: true)
        }
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
