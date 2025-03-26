import UIKit
import Combine
import KipasKipasShared
import KipasKipasLuckyDraw

protocol GiftBoxListCellControllerDelegate: AnyObject {
    func didSelectGiftBox(_ viewModel: GiftBoxViewModel)
}

final class GiftBoxListCellController: NSObject {
    
    private var cell: GiftBoxListCell?
    private var countdown: AnyCancellable?
    
    private let viewModel: GiftBoxViewModel
    
    private weak var delegate: GiftBoxListCellControllerDelegate?
    
    init(
        viewModel: GiftBoxViewModel,
        delegate: GiftBoxListCellControllerDelegate
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    private func startCountDown() {
        let viewModel = viewModel
        
        countdown = CountDownTimer(
            duration: viewModel.schedule.interval,
            repeats: false,
            outputUnits: [.hour, .minute, .second]
        )
        .handleEvents(receiveOutput: { [weak self] remaining in
            if remaining.totalSeconds < 0 {
                self?.stopCountdown()
            }
        })
        .sink(receiveValue: { [weak self] remaining in
            self?.setCountdown(
                hours: remaining.hours,
                minutes: remaining.minutes,
                seconds: remaining.seconds
            )
        })
    }
    
    private func stopCountdown() {
        countdown?.cancel()
        countdown = nil
    }
    
    private func configureCountdown() {
        if viewModel.schedule.isLessThanADay {
            cell?.setCountdown(viewModel.schedule, description: "00:00:00")
            startCountDown()
        } else {
            cell?.setCountdown(viewModel.schedule, description: nil)
        }
    }
    
    private func setCountdown(hours: Int, minutes: Int, seconds: Int) {
        let formattedHours = String(format: "%02d", hours)
        let formattedMinutes = String(format: "%02d", minutes)
        let formattedSeconds = String(format: "%02d", seconds)
        let description =  "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
        
        cell?.setCountdown(viewModel.schedule, description: description)
    }
}

// MARK: UICollectionViewDataSource
extension GiftBoxListCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        configureCountdown()
        return cell!
    }
}

// MARK: UICollectionViewDelegate
extension GiftBoxListCellController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectGiftBox(viewModel)
    }
}
