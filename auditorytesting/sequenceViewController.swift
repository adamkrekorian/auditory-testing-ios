//
//  sequenceViewController.swift
//  auditorytesting
//
//  Created by Adam Krekorian on 4/8/21.
//  Copyright © 2021 Adam Krekorian. All rights reserved.
//

import UIKit
import AVFoundation

class sequenceViewController: UIViewController {
    var seqPlayer:AVAudioPlayer?
    
    var queue = DispatchQueue(label: "seq.queue", qos: DispatchQoS.default)
    var item: DispatchWorkItem?
    
    var currentInd: Int = 0
    var currentSoundName: String = "No Sound Selected"
    var currentSoundPath: String = "No URL"
    var durationVal: Float = 5.0
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
        
        durationVal = round(10*Float(sender.value))
        durationLabel.text = "\(Int(durationVal)) seconds"
    }
    
    
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    @IBAction func delaySliderUpdate(_ sender: UISlider) {
        delayVal = UInt32(round(10*Float(sender.value)))
        delayLabel.text = "\(delayVal) seconds"
    }
    
    
    @IBOutlet weak var orb1: UIImageView!
    @IBOutlet weak var orb2: UIImageView!
    @IBOutlet weak var orb3: UIImageView!
    @IBOutlet weak var orb4: UIImageView!
    
    
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
    
    func showOrb(_ i: Int) {
        switch i {
        case 0:
            self.orb1.isHidden = false
            self.orb2.isHidden = true
            self.orb3.isHidden = true
            self.orb4.isHidden = true
            break
        case 1:
            self.orb1.isHidden = true
            self.orb2.isHidden = false
            self.orb3.isHidden = true
            self.orb4.isHidden = true
            break
        case 2:
            self.orb1.isHidden = true
            self.orb2.isHidden = true
            self.orb3.isHidden = false
            self.orb4.isHidden = true
            break
        case 3:
            self.orb1.isHidden = true
            self.orb2.isHidden = true
            self.orb3.isHidden = true
            self.orb4.isHidden = false
            break
        case 4:
            self.orb1.isHidden = true
            self.orb2.isHidden = true
            self.orb3.isHidden = true
            self.orb4.isHidden = true
            break
        default:
            self.orb1.isHidden = true
            self.orb2.isHidden = true
            self.orb3.isHidden = true
            self.orb4.isHidden = true
            break
        }
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
                DispatchQueue.main.async {
                   self?.showOrb(i)
                }
                self?.playSoundSeq(panVal: panVals[i], duration: self?.durationVal ?? 5.0)
                sleep(self?.delayVal ?? 5)
                semaphore.wait()
            }
            DispatchQueue.main.async {
                self?.showOrb(4)
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
        
        orb1.isHidden = true
        orb2.isHidden = true
        orb3.isHidden = true
        orb4.isHidden = true
    }
    

    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent && seqPlayer != nil {
            seqPlayer!.stop()
            item?.cancel()
        }
    }
}
