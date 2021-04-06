//
//  audioViewController.swift
//  auditorytesting
//
//  Created by Adam Krekorian on 4/1/21.
//  Copyright © 2021 Adam Krekorian. All rights reserved.
//

import UIKit
import AVFoundation

var player:AVAudioPlayer?

class audioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate {
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var soundNames: [String] = ["bell", "clap", "horn"]
    var sounds: [String] = ["sounds/bell.mp3", "sounds/clap.wav", "sounds/horn.wav"]
    
    
    func playSound(panVal: Float) {
        let selectRow = tableView.indexPathForSelectedRow?.row
        
        if (tableView.indexPathForSelectedRow == nil){
            return
        }
        
        let tempPath = "\(sounds[selectRow!])"
        
        let url: URL?
        if (selectRow! > 2) {
            url = URL(string: tempPath)
        } else {
            url = Bundle.main.url(forResource: tempPath, withExtension: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url!)
            player!.pan = panVal
            player!.play()
            
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    @IBAction func playLeft(_ sender: UIButton) {
        playSound(panVal:-1.0)
    }
    
    @IBAction func playRight(_ sender: UIButton) {
        playSound(panVal:1.0)
    }

    func playSoundseq(panVal: Float) {
        playSound(panVal: panVal)
    }
    
    
    @IBAction func deleteSound(_ sender: Any) {
        let selectRow = tableView.indexPathForSelectedRow?.row
        if selectRow != nil {
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
        let audioFilepath = getDocumentsDirectory().appendingPathComponent("\(audioFilename).m4a")
        if audioRecorder == nil {
                startRecording(sender, filename: audioFilename, filepath: audioFilepath)
            } else {
                finishRecording(success: true, sender: sender, filename: audioFilename, filepath: audioFilepath)
            }
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        } catch {
            print("failed to record")
        }
        
        soundNameInput.text = "recording"
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
