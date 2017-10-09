//
//  recordViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import AVFoundation

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
        } else {
            mcImage.setImage(UIImage(named: "microphone"),for: UIControlState.normal)
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
    @IBAction func SaveUpload(_ sender: Any) {
        mcImage.setImage(UIImage(named: "microphone"),for: UIControlState.normal)
        isRecording = false;
        playAudio()
        
    }
    func playAudio(){
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordName)
        
        do {
            print("audio play")
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
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
