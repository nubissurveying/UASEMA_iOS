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
import MobileCoreServices
import AVKit


class recordViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mcImage: UIButton!
    @IBOutlet weak var audioPlayButton: UIButton!
    @IBOutlet weak var videoImage: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoInstruction: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var audioUpload: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isAudioPlaying = false
    var isRecording = false
    let recordName = "recording.acc"
    let streamName = "localStream"
    let settings = Settings.getSettingFromDefault()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let saveFileName = "/test.mp4"
    var timer : Timer!
    var audioTimer = 0
    var audioUploaded = true
    override func viewDidLoad() {
        super.viewDidLoad()
        mcImage.backgroundColor = .clear
        mcImage.layer.cornerRadius = 5
        mcImage.layer.borderWidth = 1
        mcImage.layer.borderColor = UIColor.black.cgColor
        
        audioPlayButton.backgroundColor = .clear
        audioPlayButton.layer.cornerRadius = 5
        audioPlayButton.layer.borderWidth = 1
        audioPlayButton.layer.borderColor = UIColor.black.cgColor
        audioPlayButton.isEnabled = false
        
        audioUpload.backgroundColor = .clear
        audioUpload.layer.cornerRadius = 5
        audioUpload.layer.borderWidth = 1
        audioUpload.layer.borderColor = UIColor.black.cgColor
        audioUpload.isEnabled = false
        
        videoImage.backgroundColor = .clear
        videoImage.layer.cornerRadius = 5
        videoImage.layer.borderWidth = 1
        videoImage.layer.borderColor = UIColor.black.cgColor
        
//        playButton.backgroundColor = .clear
//        playButton.layer.cornerRadius = 5
//        playButton.layer.borderWidth = 1
//        playButton.layer.borderColor = UIColor.black.cgColor
        
        
        
        timerLabel.text = "00:00"
        audioTimer = 0;
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        setRecordingSession()
        audioPlayButton.isEnabled = false
//        setVideo()
        
        
    }
    //hide the video part if video is set to not show
    func setVideo(){
        if(settings.getVid() != 1){
            videoImage.isEnabled = false
            videoImage.isHidden = true
//            playButton.isHidden = true
            videoInstruction.isHidden = true
        }
    }
    func setRecordingSession(){
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //video part
    @IBAction func videoRecord(_ sender: Any) {
        print("here to record video")
        imagePicker.videoMaximumDuration = TimeInterval(Constants.videoMaximumDuration)
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
                imagePicker.delegate = self
                
                
                present(imagePicker, animated: true, completion: {})
            } else {
                postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
    }
    
    @IBAction func VideoUpload(_ sender: Any) {
        print("here to upload video","play the last recording")
        // Find the video in the app's document directory
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let dataPath = documentsDirectory.appendingPathComponent(saveFileName)
        print(dataPath.absoluteString)
        let videoAsset = (AVAsset(url: dataPath))
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        // Play the video
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate delegate methods
    // Finished recording a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got a video")
        
        if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
            // Save video to the main photo album
            let selectorToCall = #selector(recordViewController.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath, self, selectorToCall, nil)
            
            // Save the video to the app directory so we can play it later
            let videoData = try? Data(contentsOf: pickedVideo)
            
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(saveFileName)
            try! videoData?.write(to: dataPath, options: [])
            print("Saved to " + dataPath.absoluteString)
        }
        
        imagePicker.dismiss(animated: true, completion: {
            print("imagePicker", "dismiss and upload")
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(self.saveFileName)
            
            //if video less than 10s refuse to upload
            let asset = AVAsset(url:dataPath)
            let duration = asset.duration
            let durationTime = CMTimeGetSeconds(duration)
            print("check upload ", " video length is \(durationTime)")
            if(durationTime < 10){
                print("check upload", "too short to upload")
                self.view.showToast("too short to upload", position: .bottom, popTime: 2, dismissOnTap: false)
            } else {
                self.uploadWithDelayedAnswer(url: dataPath, minType: "video/mp4", fileName: "test.mp4")
                self.view.showToast("uploading video", position: .bottom, popTime: 2, dismissOnTap: false)
            }
            
        })
    }
    
    // Called when the user selects cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User canceled image")
        dismiss(animated: true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    // Any tasks you want to perform after recording a video
    @objc func videoWasSavedSuccessfully(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                // What you want to happen
            })
        }
    }
    
    
    // MARK: Utility methods for app
    // Utility method to display an alert to the user.
    func postAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    

    
    //audio part
    @IBAction func MicActon(_ sender: Any) {
        if(isRecording){
            mcImage.setImage(UIImage(named: "microphone_check"), for: UIControlState.normal)
            isRecording = false;
            self.finishRecording(success: true)
            timer.invalidate()
            audioPlayButton.isEnabled = true
            audioUpload.isEnabled = true
            audioUpload.setTitleColor(UIColor.black, for: .normal)
            audioPlayButton.setTitleColor(UIColor.black, for: .normal)
            audioUploaded = false
        } else {
            
            mcImage.setImage(UIImage(named: "microphone_recording"),for: UIControlState.normal)
            isRecording = true;
            self.startRecording()
            audioTimer = 0;
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }
    }
    
    
    func startRecording() {
        print("start recording")
        self.view.showToast("start recording, press again to stop", position: .bottom, popTime: 2, dismissOnTap: false)
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
    
    //audio playing function
    @IBAction func playAudio(_ sender: Any) {
        if(isAudioPlaying){
            audioPlayer.stop()
            isAudioPlaying = false
            print("stop playing audio")
            audioPlayButton.setTitle("Play", for: .normal)
        } else {
            playAudio()
            audioPlayButton.setTitle("Stop", for: .normal)
            
        }

    }
    //change button back to play
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayButton.setTitle("Play", for: .normal)
    }
    @IBAction func Upload(_ sender: Any) {
        if(!audioUploaded){
            mcImage.setImage(UIImage(named: "microphone"),for: UIControlState.normal)
            isRecording = false;
            
            uploadAudio(url: getDocumentsDirectory().appendingPathComponent(recordName))
            audioUploaded = true
            resetTimer()
        } else {
            self.view.showToast("nothing to upload", position: .bottom, popTime: 3, dismissOnTap: false)
        }
        
    }
    func uploadAudio(url : URL){
        self.mcImage.isEnabled  = false
        self.audioPlayButton.isEnabled = false
        
//        var now = Date()
        let soundrecorded = FileManager.default.fileExists(atPath: url.path)
        if(soundrecorded){
            self.view.showToast("uploading", position: .bottom, popTime: 3, dismissOnTap: false)
            
//            removeFileAt(url: url)
        } else {
            self.view.showToast("nothing to upload", position: .bottom, popTime: 3, dismissOnTap: false)
        }
        uploadWithDelayedAnswer(url: url,minType: "audio/x-aac",fileName: "test.acc")
        
        self.mcImage.isEnabled  = true
        self.audioPlayButton.isEnabled = true
    }
    func uploadWithDelayedAnswer(url : URL, minType: String, fileName: String){
        print("try to upload using alamofire")
        
        
//        let localBase = "http://10.120.65.133:8888/ema/index.php"
        let delayedAnswer = NubisDelayedAnswer(type: NubisDelayedAnswer.N_POST_FILE)
        dispatchDelayedAnswer(delayedAnswer: delayedAnswer, url: url)

        print("here comes upload encrypt string", Encrypt(inputStr: delayedAnswer.getGetString()!))

//        print(Constants.baseURL + "?ema=1&q=" + Encrypt(inputStr: delayedAnswer.getGetString()!))
//        print(localBase + "?ema=1&q=" + Encrypt(inputStr: delayedAnswer.getGetString()!))

        uploadFile(filePath: url, uploadURL: Constants.baseURL + "?ema=1&q=" + Encrypt(inputStr: delayedAnswer.getGetString()!), mimeType: minType, fileName: fileName)
        
        print("end uploading using alamofire")
    }
    func dispatchDelayedAnswer(delayedAnswer : NubisDelayedAnswer, url: URL){
        
        let dic = Bundle.main.infoDictionary!
        let buildNumber = dic["CFBundleVersion"]! as! String
        delayedAnswer.addGetParameter(key: "version", value: buildNumber)
        delayedAnswer.addGetParameter(key: "rtid", value: settings.getRtid()!)
        delayedAnswer.addGetParameter(key: "phonets", value: DateUtil.stringifyAllAlt(calendar: Date()))
        delayedAnswer.addGetParameter(key: "p", value: "openendedsound")
        delayedAnswer.addGetParameter(key: "ema", value: "1")
        delayedAnswer.addFileName(filename: url.path)
        //        delayedanswer.setByteArrayOutputStream()
        let output = OutputStream(toFileAtPath: getDocumentsDirectory().appendingPathComponent(streamName).path, append:true)
        output?.open()
        var input = NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_boundary + NubisDelayedAnswer.N_lineEnd
        output?.write(input, maxLength: input.count)
        
        input = "Content-Disposition: form-data; name=\"uploadedfile\";filename=\"" + "test" + "\"" + NubisDelayedAnswer.N_lineEnd
        output?.write(input, maxLength: input.count)
        
        output?.write(NubisDelayedAnswer.N_lineEnd, maxLength: NubisDelayedAnswer.N_lineEnd.count)
        delayedAnswer.getByteArrayOutputStream(output: output!)
        
        output?.write(NubisDelayedAnswer.N_lineEnd, maxLength: NubisDelayedAnswer.N_lineEnd.count)
        input = NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_boundary + NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_lineEnd
        output?.write(input, maxLength: input.count)
        output?.close()
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
            isAudioPlaying = true
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
            self.view.showToast("audioPlayer error \(error.localizedDescription)", position: .bottom, popTime: 3, dismissOnTap: true)
        }
    }
    // encryption the info
    public func Encrypt(inputStr:String)->String{
        do {
            let mcrypt = MCrypt();
            return try MCrypt.bytesToHex( data: mcrypt.encrypt(text: inputStr)! )!;
        }
        catch let error as NSError{
            print("mycrypt in record uploading error \(error.localizedDescription)")
        }
        return inputStr;
    }
    
    //upload audio
    func uploadFile(filePath : URL, uploadURL: String, mimeType: String, fileName: String){
        print("record upload", uploadURL)
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                multipartFormData.append(filePath, withName: "uploadedfile", fileName: fileName, mimeType: mimeType)

        },to: uploadURL,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):

                upload.responseJSON { response in

                    guard let result = response.result.value else { return }
                    print("json:\(result)")
                }

                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("audio upload progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    // timer
    @objc func runTimer() {
        audioTimer += 1
        timerLabel.text = String(format: "%02d:%02d", audioTimer/60, audioTimer % 60)
        
    }
    
    func resetTimer() {
        audioTimer = 0
        timerLabel.text = "00:00"
    }

}
