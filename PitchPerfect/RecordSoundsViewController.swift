//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Philip Adeyeye on 26/12/2018.
//  Copyright © 2018 Philip Adeyeye. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, CLLocationManagerDelegate {

    var audioRecorder: AVAudioRecorder!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var stopRecordButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        record.layer.cornerRadius = 10
        record.clipsToBounds = true
        setRecordingButton(true)
    }

    @IBAction func recordAudio(_ sender: Any) {
        initAudioRecorder()
    }
    
    @IBAction func stopAudio(_ sender: Any) {
         stopRecorder()
         // startReceivingLocationChanges()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundViewController
            let recorderAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recorderAudioURL
        }
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways) || !CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            print("Location access not allowed")
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 250.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func setRecordingButton(_ shouldStart: Bool) {
        record.isEnabled = shouldStart
        stopRecordButton.isEnabled = !shouldStart
        recordingLabel.text = shouldStart ? "Tap to record" : "Recording in progress"
    }
    
    func initAudioRecorder() {
        setRecordingButton(false)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecorder() {
        setRecordingButton(true)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        print(lastLocation as Any);
    }
    
}
