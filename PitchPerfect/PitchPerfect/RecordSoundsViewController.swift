//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by jay on 8/10/17.
//  Copyright © 2017 JayGabriel. All rights reserved.
//
//  ** Updated 8/23/2017
//  ** - Embedded recordingLabel, recordButton, and stopRecording in a stack view

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecording: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecording.isEnabled = false
    }

    @IBAction func recordAudio(_ sender: Any) {
        toggleRecording(recording: true)
        
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = "voice.wav"
        let pathArray = [directoryPath, fileName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        toggleRecording(recording: false)
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording failed.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    func toggleRecording(recording: Bool) {
        if recording == false {
            recordingLabel.text = "Tap to record"
            recordButton.isEnabled = true
            stopRecording.isEnabled = false
            audioRecorder.stop()
        } else {
            recordingLabel.text = "Recording in process"
            recordButton.isEnabled = false
            stopRecording.isEnabled = true
        }
    }
    
}

