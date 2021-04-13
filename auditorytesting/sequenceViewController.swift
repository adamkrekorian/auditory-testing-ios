//
//  sequenceViewController.swift
//  auditorytesting
//
//  Created by Adam Krekorian on 4/8/21.
//  Copyright © 2021 Adam Krekorian. All rights reserved.
//

import UIKit
import AVFoundation

var seqPlayer:AVAudioPlayer?

class sequenceViewController: UIViewController {
    var queue = DispatchQueue(label: "home.queue", qos: DispatchQoS.default)
    var item: DispatchWorkItem?
    
    var currentInd: Int = 0
    var currentSoundName: String = "No Sound Selected"
    var currentSoundPath: String = "No URL"
    var durationVal: Float = 15.0
    var delayVal: UInt32 = 5
    var url: URL?
    
    @IBOutlet weak var currentSound: UILabel!
    
    @IBOutlet weak var LR1: UISegmentedControl!
    @IBOutlet weak var LR2: UISegmentedControl!
    @IBOutlet weak var LR3: UISegmentedControl!
    @IBOutlet weak var LR4: UISegmentedControl!

    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBAction func durationSliderUpdate(_ sender: UISlider) {
        
        durationVal = round(30*Float(sender.value))
        durationLabel.text = "\(durationVal) seconds"
    }
    
    
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    @IBAction func delaySliderUpdate(_ sender: UISlider) {
        delayVal = UInt32(round(30*Float(sender.value)))
        delayLabel.text = "\(delayVal) seconds"
    }
    
    
    func segmentToPan(_ seg: UISegmentedControl) -> Float {
        switch seg.selectedSegmentIndex {
        case 0:
            return -1.0
        case 1:
            return 1.0
        default:
            return -1.0
        }
    }
    
    func prepareSoundSeq() {
        if (currentInd > 2) {
            url = URL(string: currentSoundPath)
        } else {
            url = Bundle.main.url(forResource: currentSoundPath, withExtension: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func playSoundSeq(panVal: Float, duration: Float) {
        do {
            seqPlayer = try AVAudioPlayer(contentsOf: self.url!)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        seqPlayer!.pan = panVal
        seqPlayer!.play()
        sleep(UInt32(duration))
        seqPlayer!.stop();
//        Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { (timer) in
//            seqPlayer!.stop()}
    }
    
    @IBAction func playSequence(_ sender: UIButton) {
        let panVals = [self.segmentToPan(self.LR1),
                       self.segmentToPan(self.LR2),
                       self.segmentToPan(self.LR3),
                       self.segmentToPan(self.LR4)]
        
        queue.async() { self.prepareSoundSeq() }
        
        item = DispatchWorkItem { [weak self] in
            for i in 0...3 where self?.item?.isCancelled == false {
                let semaphore = DispatchSemaphore(value: 0)
                semaphore.signal()
                self?.playSoundSeq(panVal: panVals[i], duration: self?.durationVal ?? 5.0)
                sleep(self?.delayVal ?? 5)
                semaphore.wait()
            }
            self?.item = nil
        }

        queue.async(execute: item!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentSound.text = currentSoundName
        if (currentInd > 2) {
            url = URL(string: currentSoundPath)
        } else {
            url = Bundle.main.url(forResource: currentSoundPath, withExtension: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        item?.cancel()
    }
}
