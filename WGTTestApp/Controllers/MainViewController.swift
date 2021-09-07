import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    @IBOutlet weak var playerStackView: UIStackView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    let photoCellID = "imageCell"
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 10.0, right: 0)
    private let itemsPerRow: CGFloat = 1
    
    @IBOutlet weak var excursionNameLabel: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var currentExcursion: ExcursionModel? = nil
    var currentStepIndex: Int? = nil
    
    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        excursionNameLabel.text = currentExcursion?.name
        descriptionLabel.text = currentExcursion?.steps[currentStepIndex ?? 0].name
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.contentInsetAdjustmentBehavior = .never
        
        setUpPlayer()
        setUpSlider()
        setUpStackView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.pause()
    }
    
    fileprivate func setUpPlayer() {
        let url = currentExcursion?.steps[currentStepIndex ?? 0].audioURL
        guard let url = url else { return }
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { cmTime in
            if self.player?.currentItem?.status == .readyToPlay {
                let time = CMTimeGetSeconds((self.player?.currentTime())!)
                self.playbackSlider.value = Float(time)
            }
            
            if self.player?.rate == 0 {
                self.playPauseButton.setImage(#imageLiteral(resourceName: "play-2"), for: .normal)
            } else {
                self.playPauseButton.setImage(#imageLiteral(resourceName: "pause-2"), for: .normal)
            }
            
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        player?.seek(to: CMTime.zero)
        playPauseButton.setImage(#imageLiteral(resourceName: "013-play"), for: .normal)
    }
    
    fileprivate func setUpSlider() {
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playbackSlider.maximumValue = Float(seconds)
        playbackSlider.isContinuous = true
        playbackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.setThumbImage(#imageLiteral(resourceName: "rec (1)"), for: .normal)
        playbackSlider.setThumbImage(#imageLiteral(resourceName: "rec (1)"), for: .highlighted)
    }
    
    fileprivate func setUpStackView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector (showPlayerVC) )
        playerStackView.addGestureRecognizer(tap)
        playerStackView.layer.cornerRadius = 10
    }
    
    @objc func showPlayerVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "playerVC") as! PlayerViewController
        vc.currentExcursion = self.currentExcursion
        vc.currentStepIndex = self.currentStepIndex
        vc.player = self.player
        present(vc, animated: true)
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
    
    @IBAction func closeVCButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        player?.pause()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if player?.rate == 0 {
            player?.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause-2"), for: .normal)
        } else {
            player?.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play-2"), for: .normal)
        }
    }
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        stepSeek(to: .backward)
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        stepSeek(to: .forward)
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
    
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentExcursion?.steps[0].imagesURLs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: photoCellID, for: indexPath) as! PhotoTableViewCell
        cell.imageView.image = nil
        let imageURL = URL(string: (currentExcursion?.steps[0].imagesURLs[indexPath.row])!)!
        cell.imageView.load(url: imageURL)
        
        return cell
    }
}


extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvRect = photoCollectionView.frame
        return CGSize(width: cvRect.width, height: cvRect.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

