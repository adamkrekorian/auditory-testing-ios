//
//  audioViewController.swift
//  auditorytesting
//
//  Created by Adam Krekorian on 4/1/21.
//  Copyright © 2021 Adam Krekorian. All rights reserved.
//

import UIKit
import AVFoundation

class audioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
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
        if audioRecorder != nil { alertRecording() }
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
        if audioRecorder != nil { alertRecording() }
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
        if audioRecorder != nil { alertRecording() }
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
        
        if player != nil {
            cancelPlaying()
        }
        
        do {
            audioRecorder = try AVAudioRecorder(url: filepath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            print("File saved at \(filepath)")
            let button = sender as! UIButton
            button.setTitle("Tap to Stop", for: .normal)
            button.backgroundColor = UIColor(red: 240/255, green: 10/255, blue: 15/255, alpha: 0.5)
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
        
        let button = sender as! UIButton
        if success {
            button.setTitle("Record", for: .normal)
            button.backgroundColor = UIColor.systemGray4
        } else {
            button.setTitle("Try Again", for: .normal)
        }
    }
    
    func alertRecording() {
        let alert = UIAlertController(title: "Recording in Progress", message: "Please finish recording before playing back a sound.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
    
    @IBAction func recordSound(_ sender: Any) {
        let audioFilename: String = soundNameInput.text!
        let audioFilenameClean = audioFilename.replacingOccurrences(of: " ", with: "_")
        
        if audioFilenameClean == "" {
            let alert = UIAlertController(title: "No Recording Name", message: "Please name your recording.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            return
        }
        else if soundNames.contains(audioFilenameClean)  {
            let alert = UIAlertController(title: "Please rename sound", message: "You cannot have duplicate sound names", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            return
        }
        else {
            let audioFilepath = getDocumentsDirectory().appendingPathComponent("\(audioFilenameClean).m4a")
            if audioRecorder == nil {
                    startRecording(sender, filename: audioFilenameClean, filepath: audioFilepath)
                } else {
                    finishRecording(success: true, sender: sender, filename: audioFilenameClean, filepath: audioFilepath)
                }
        }
    }
    
    @IBOutlet weak var soundNameInput: UITextField!
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = soundNameInput.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 18
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        soundNameInput.delegate = self
        
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
        if audioRecorder != nil { alertRecording() }
        self.performSegue(withIdentifier: "segueSequence", sender: self)
        if player != nil {
            cancelPlaying()
        }
    }
    
    @IBAction func goToInstruction(_ sender: UIButton) {
        if audioRecorder != nil { alertRecording() }
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
    
    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }

}


//extension Date
//{
//    func toString( dateFormat format  : String ) -> String
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        return dateFormatter.string(from: self)
//    }
//}
//            let audioFilepath = getDocumentsDirectory().appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
