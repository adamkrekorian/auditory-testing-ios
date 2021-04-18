//
//  audioViewController.swift
//  auditorytesting
//
//  Created by Adam Krekorian on 4/1/21.
//  Copyright © 2021 Adam Krekorian. All rights reserved.
//

import UIKit
import AVFoundation

class audioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    let NUMBER_OF_PRELOADED_SOUNDS = 6
    
    var player:AVAudioPlayer?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var soundNames: [String] = ["Bell Ringing", "Clapping", "Horn", "Birds Chirping","Car Engine", "Dog Barking"]
    var sounds: [String] = ["sounds/bell.mp3", "sounds/clap.mp3", "sounds/horn.wav","sounds/birds.mp3","sounds/car_engine.wav","sounds/bark.wav"]
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    func cancelPlaying() {
        player!.stop()
        player = nil
        if (leftButton.titleLabel?.text == "Tap to Stop") {
            leftButton.setTitle("Play Left", for: .normal)
        }
        if (rightButton.titleLabel?.text == "Tap to Stop") {
            rightButton.setTitle("Play Right", for: .normal)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player_static: AVAudioPlayer, successfully flag: Bool) {
        if (flag == true) { cancelPlaying() }
    }
    
    func playSound(_ sender: Any, _ panVal: Float) {
        let selectRow = tableView.indexPathForSelectedRow?.row
        
        if (tableView.indexPathForSelectedRow == nil){
            return
        }
        
        let tempPath = "\(sounds[selectRow!])"
        
        let url: URL?
        if (selectRow! >= NUMBER_OF_PRELOADED_SOUNDS) {
            url = URL(string: tempPath)
        } else {
            url = Bundle.main.url(forResource: tempPath, withExtension: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try url?.checkResourceIsReachable()
            
            player = try AVAudioPlayer(contentsOf: url!)
            player?.delegate = self
            player!.pan = panVal
            player!.play()
            let button = sender as! UIButton
            button.setTitle("Tap to Stop", for: .normal)
            
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    

    @IBAction func playLeft(_ sender: UIButton) {
        let panVal: Float = -1.0;
        if player == nil || sender.titleLabel?.text == "Play Left" {
            playSound(sender, panVal)
            if (rightButton.titleLabel?.text == "Tap to Stop") {
                rightButton.setTitle("Play Right", for: .normal)
            }
        } else {
            cancelPlaying()
        }
    }
    
    
    @IBAction func playRight(_ sender: UIButton) {
        let panVal: Float = 1.0;
        if player == nil || sender.titleLabel?.text == "Play Right" {
            playSound(sender, panVal)
            if (leftButton.titleLabel?.text == "Tap to Stop") {
                leftButton.setTitle("Play Left", for: .normal)
            }
        } else {
            cancelPlaying()
        }
    }

    @IBAction func deleteSound(_ sender: Any) {
        let selectRow = tableView.indexPathForSelectedRow?.row
        if selectRow != nil && selectRow! >= NUMBER_OF_PRELOADED_SOUNDS {
            soundNames.remove(at: selectRow!)
            sounds.remove(at: selectRow!)
            self.tableView.reloadData()
        }
    }
    
    func startRecording(_ sender: Any, filename: String, filepath: URL) {

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: filepath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            print("File saved at \(filepath)")
            let button = sender as! UIButton
            button.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false, sender: sender, filename: filename, filepath: filepath)
        }
    }
    
    func finishRecording(success: Bool, sender: Any, filename: String, filepath: URL) {
        audioRecorder.stop()
        audioRecorder = nil
        soundNames.append(filename)
        sounds.append(filepath.absoluteString)
        self.tableView.reloadData()
        print(sounds)
        
        let button = sender as! UIButton
        if success {
            button.setTitle("Record", for: .normal)
        } else {
            button.setTitle("Try Again", for: .normal)
        }
    }
    
    
    @IBOutlet weak var soundNameInput: UITextField!
    
    @IBAction func recordSound(_ sender: Any) {
        let audioFilename: String = soundNameInput.text!
        
        if audioFilename == "" {
            let alert = UIAlertController(title: "No Recording Name", message: "Please name your recording.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
        else if soundNames.contains(audioFilename)  {
            let alert = UIAlertController(title: "Please rename sound", message: "You cannot have duplicate sound names", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
        else {
            let audioFilepath = getDocumentsDirectory().appendingPathComponent("\(audioFilename).m4a")
            if audioRecorder == nil {
                    startRecording(sender, filename: audioFilename, filepath: audioFilepath)
                } else {
                    finishRecording(success: true, sender: sender, filename: audioFilename, filepath: audioFilepath)
                }
        }
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //self.navigationController?.isNavigationBarHidden = true
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("ready to record!")
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        soundNameInput.text = ""
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customSoundCell") as! customSoundCell
        cell.soundId?.text = soundNames[indexPath.row]
        
        return cell
    }
    
    @IBAction func goToSequence(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueSequence", sender: self)
        if player != nil {
            cancelPlaying()
        }
    }
    
    @IBAction func goToInstruction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueInstruction", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segueSequence") {
            let selectRow = tableView.indexPathForSelectedRow?.row ?? nil
            let controller = segue.destination as! sequenceViewController

            if (selectRow != nil) {
                controller.currentInd = selectRow!
                controller.currentSoundName =  soundNames[selectRow!]
                controller.currentSoundPath =  sounds[selectRow!]
            } else {
               let alert = UIAlertController(title: "No Sound Selected", message: "Please select a sound to create a sequence", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
