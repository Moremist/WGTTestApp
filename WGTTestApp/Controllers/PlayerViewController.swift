import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    var currentExcursion: ExcursionModel? = nil
    var currentStepIndex: Int? = nil
    
    var player: AVPlayer? = nil
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    @IBOutlet weak var stepNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playBackSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpExcursionData()
        setUpPlayer()
        setUpSlider()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
    }
    
    fileprivate func setUpExcursionData() {
        stepNameLabel.text = currentExcursion?.steps[currentStepIndex ?? 0].name
        excursionNameLabel.text = currentExcursion?.name
        textView.text = currentExcursion?.steps[0].text
    }
    
    fileprivate func setUpPlayer() {
        if player?.rate == 0 {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play-2"), for: .normal)
        } else {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause-2"), for: .normal)
        }
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { cmTime in
            if self.player?.currentItem?.status == .readyToPlay {
                let time = CMTimeGetSeconds((self.player?.currentTime())!)
                self.playBackSlider.value = Float(time)
            }
        })
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause-2"), for: .normal)
            player?.play()
        }
    }
    
    fileprivate func setUpSlider() {
        let duration : CMTime = (player?.currentItem!.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        playBackSlider.setThumbImage(#imageLiteral(resourceName: "rec (1)"), for: .normal)
        playBackSlider.setThumbImage(#imageLiteral(resourceName: "rec (1)"), for: .highlighted)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if player?.rate == 0 {
            player?.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause-2"), for: .normal)
        } else {
            player?.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play-2"), for: .normal)
        }
    }
    
    @IBAction func stepsButtonressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "stepsVC") as! StepsViewController
        vc.currentExcursion = self.currentExcursion
        vc.currentStepIndex = self.currentStepIndex
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        stepSeek(to: .forward)
    }
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        stepSeek(to: .backward)
    }
    
    fileprivate func stepSeek(to: StepDirection) {
        if player == nil { return }
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            var multiplyer = 0
            switch to {
            case .backward:
                multiplyer = -1
            case .forward:
                multiplyer = 1
            }
            let newTime = playerCurrentTime + Settings.shared.seekDuration * Double(multiplyer)
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


