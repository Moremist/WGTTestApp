import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    var currentExcursion: ExcursionModel? = nil
    var player: AVPlayer? = nil
    
    @IBOutlet weak var excursionLabel: UILabel!
    @IBOutlet weak var playerStavkView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playBackSlider: UISlider!
    let seekDuration : Float64 = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpStackView()
        setUpExcursionData()
        setUpPlayer()
    }
    
    fileprivate func setUpExcursionData() {
        excursionLabel.text = currentExcursion?.name
        textView.text = currentExcursion?.steps[0].text
    }
    
    fileprivate func setUpPlayer() {
        if player?.rate == 0 {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "013-play"), for: .normal)
        } else {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "021-pause"), for: .normal)
        }
        
        let duration : CMTime = (player?.currentItem!.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
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
            playPauseButton.setImage(#imageLiteral(resourceName: "021-pause"), for: .normal)
            player?.play()
        }
    }
    
    fileprivate func setUpStackView() {
        playerStavkView.layer.cornerRadius = 10
    }
    
    fileprivate func swithPlayPause() {
        if player?.rate == 0 {
            player?.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "021-pause"), for: .normal)
        } else {
            player?.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "013-play"), for: .normal)
        }
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        swithPlayPause()
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        if player == nil { return }
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        if player == nil { return }
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime - seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
}
