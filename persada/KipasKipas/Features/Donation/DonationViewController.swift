//
//  DonationViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class DonationViewController: UIViewController {
    
    @IBOutlet weak var activeTotalLabel: UILabel!
    @IBOutlet weak var inactiveTotalLabel: UILabel!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var activeTitleLabel: UILabel!
    @IBOutlet weak var inactiveTitleLabel: UILabel!
    @IBOutlet weak var leadingIndicatorConstraint: NSLayoutConstraint!
    
    enum DonationStatus {
        case active, inactive
    }
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var viewControllerList: [UIViewController] = []
    private var previousMenu: Int = 0
    private let activeController = DonationListViewController(isActive: true)
    private let inactiveController = DonationListViewController(isActive: false)
    private var donationStatus: DonationStatus = .active {
        didSet {
            activeTitleLabel.textColor = donationStatus == .active ? .primary : .grey
            inactiveTitleLabel.textColor = donationStatus == .inactive ? .primary : .grey
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Penggalangan Dana"
        setupPageViewController()
        requestDonations(isActive: true)
        requestDonations(isActive: false)
    }
    
    private func setupPageViewController() {
        viewControllerList = [activeController, inactiveController]
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.setViewControllers([viewControllerList[0]], direction: .forward, animated: true, completion: nil)
        updateIndicatorViewPosition(menu: 0)
        
        view.insertSubview(pageViewController.view, at: 0)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 4),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        for v in pageViewController.view.subviews {
            if v.isKind(of: UIScrollView.self) {
                (v as! UIScrollView).delegate = self
            }
        }
    }
    
    private func updateIndicatorViewPosition(menu: Int) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.leadingIndicatorConstraint.constant = (self.view.bounds.width / 2 * CGFloat(menu))
                self.tabView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction private func didSelectFundraisingStatus(_ sender: UIButton) {
        donationStatus = sender.tag == 0 ? .active : .inactive
        
        pageViewController.setViewControllers([viewControllerList[sender.tag]], direction: previousMenu > sender.tag ? .reverse : .forward, animated: true, completion: nil)
        
        previousMenu = sender.tag
        tabButtons.forEach { button in
            button.isSelected =  button.tag != sender.tag
            updateIndicatorViewPosition(menu: sender.tag)
        }
    }
}

extension DonationViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        return viewControllerList[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        return viewControllerList[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        guard let currentViewController = pageViewController.viewControllers?.first else { return }
        guard let index = viewControllerList.firstIndex(of: currentViewController) else { return }
        
        updateIndicatorViewPosition(menu: index)
        donationStatus = index == 0 ? .active : .inactive
    }
}

extension DonationViewController: UIScrollViewDelegate {}

extension DonationViewController {
    func requestDonations(isActive: Bool) {
        let network = DIContainer.shared.apiDataTransferService
        
        let endpoint: Endpoint<RemoteDonation?> = Endpoint(
            path: "donations",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: [
                "page": 0,
                "size": 1,
                "status": isActive ? "ACTIVE" : "INACTIVE",
                "initiatorId": getIdUser(),
                "sort": "createAt,desc"
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result, let data = response?.data {
                if isActive {
                    self.activeTotalLabel.text = "\(data.totalElements ?? 0)"
                } else {
                    self.inactiveTotalLabel.text = "\(data.totalElements ?? 0)"
                }
            }
        }
    }
}
