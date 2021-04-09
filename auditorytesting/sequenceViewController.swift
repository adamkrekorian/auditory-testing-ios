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
    
    var currentInd: Int = 0;
    var currentSoundName: String = "No Sound Selected";
    var currentSoundPath: String = "No URL";
    var durationVal: Float = 15.0;
    
    @IBOutlet weak var currentSound: UILabel!
    
    @IBOutlet weak var LR1: UISegmentedControl!
    
    @IBOutlet weak var LR2: UISegmentedControl!
    
    @IBOutlet weak var LR3: UISegmentedControl!
    
    @IBOutlet weak var LR4: UISegmentedControl!
    
    
    
    @IBOutlet weak var durationSlider: UISlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBAction func durationSliderUpdate(_ sender: UISlider) {
        
        durationVal = round(30*Float(sender.value));
        durationLabel.text = "\(durationVal) seconds";
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
        let url: URL?
        if (currentInd > 2) {
            url = URL(string: currentSoundPath)
        } else {
            url = Bundle.main.url(forResource: currentSoundPath, withExtension: nil)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            seqPlayer = try AVAudioPlayer(contentsOf: url!)
            
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func playSoundSeq(panVal: Float, duration: Float) {
        seqPlayer!.pan = panVal
        seqPlayer!.play();
        Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { (timer) in
            seqPlayer!.stop()}
    }
    
    @IBAction func playSequence(_ sender: UIButton) {
        prepareSoundSeq();
        playSoundSeq(panVal: segmentToPan(LR1), duration: 5.0);
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.playSoundSeq(panVal: self.segmentToPan(self.LR2), duration: 5.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0*2+0.01) {
            self.playSoundSeq(panVal: self.segmentToPan(self.LR3), duration: 5.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0*3+0.01) {
            self.playSoundSeq(panVal: self.segmentToPan(self.LR4), duration: 5.0)
        }
        print("finished");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentSound.text = currentSoundName
        // Do any additional setup after loading the view.
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
