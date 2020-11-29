//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ali Şahbaz on 28.11.2020.
//

import UIKit
import AVFoundation

class RecordSoundsViewController : UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        stopButton.isEnabled = false
    }
    
    func activateRecording(isActive: Bool){
        recordButton.isEnabled = isActive
        recordLabel.text = isActive ? "Tap to Record" :"Recording in Progress"
        stopButton.isEnabled = !isActive
    }
    
    @IBAction func recordButtonClicked(_ sender: Any) {
        activateRecording(isActive: false)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch {
            showAlert(Alerts.AudioSessionError, message: Alerts.RecordingFailedMessage)
            
        }
        do {
            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        } catch {
            showAlert(Alerts.AudioRecorderError, message: Alerts.RecordingFailedMessage)
            
        }

        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        activateRecording(isActive: true)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let vc = segue.destination as! PlaySoundsViewController
            let recordedUrl = sender as! URL
            vc.recordedAudioURL = recordedUrl
        }
    }
    
}

extension RecordSoundsViewController : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool){
        if flag == true {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }
        else {
            showAlert(Alerts.RecordingFailedTitle, message: Alerts.RecordingFailedMessage)
        }
    }
}
