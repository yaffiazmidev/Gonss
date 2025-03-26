//
//  ComplaintController.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import AVKit
import KipasKipasShared

protocol ComplaintDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: ComplaintModel.ViewModel)
}

final class ComplaintController: UIViewController, Displayable, ComplaintDisplayLogic, AlertDisplayer {
	
	private let mainView: ComplaintView
	private var interactor: ComplaintInteractable!
	private var router: ComplaintRouting!
	private var reasonComplaint: [String] = [
        "Barang tidak sesuai dengan yang dipesan (salah kirim barang)",
        "Barang tidak sesuai dengan deskripsi (beda ukuran dan warna)",
		"Barang rusak",
		"Barang hilang",
		"Barang cacat produksi",
		"Alasan lainnya"
	]
	
	var videoURL: [String] = []
	var selectedItem = [UIImage]()
	var imageURL: [String] = []
	var isLoading: Bool = false
	var isMediaAvailable = false
	var indexCollection = 0
	var isSelect = false
	
	private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    lazy var imagePickerController: KKCameraViewController = {
        let vc = KKCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
	
	init(mainView: ComplaintView, dataSource: ComplaintModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = ComplaintInteractor(viewController: self, dataSource: dataSource)
		router = ComplaintRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(.get(.detailTransaction))
		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationItem.title = String.get(.complaint)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - ComplaintDisplayLogic
	func displayViewModel(_ viewModel: ComplaintModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .complaint(let viewModel):
				self.displayComplaint(viewModel)
			case .media(let viewModel):
				self.responseUpload(viewModel)
			case .error(let error):
				self.presentError(error)
			}
		}
	}
}


// MARK: - ComplaintViewDelegate
extension ComplaintController: ComplaintViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  10
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
		case 0, 1, 2, 3, 4, 5:
			let cell = tableView.dequeueReusableCustomCell(with: ComplaintTextItemCell.self, indexPath: indexPath)
			cell.titleLabel.text = reasonComplaint[indexPath.row]
			return cell
		case 6:
			let cell = tableView.dequeueReusableCustomCell(with: ComplaintReasonItemCell.self, indexPath: indexPath)
			cell.selectionStyle = .none
			let textValid = cell.captionCTV.nameTextField.text
			
			if textValid != nil && textValid == "" {
				interactor.dataSource.reason = textValid ?? ""
			}
			
			print("valid text \(textValid ?? "")")
			return cell
		case 7:
			let cell = tableView.dequeueReusableCustomCell(with: ComplaintProveVideoItemCell.self, indexPath: indexPath)
			cell.selectionStyle = .none
			
			return cell
		case 8:
			let cell = tableView.dequeueReusableCustomCell(with: ComplaintChoiceVideoItemCell.self, indexPath: indexPath)
			
			cell.handleMedia = { [weak self] in
				guard let self = self else { return }
				self.showPicker(0)
			}
			
			if let imageMedia = interactor.dataSource.image {
				cell.iconImageView.image = imageMedia
			} else  {
				cell.iconImageView.image = UIImage(named: String.get(.btnAddMedia))
			}
			
			cell.selectionStyle = .none
			
			return cell
		case 9:
			let cell = tableView.dequeueReusableCustomCell(with: ComplaintConfirmItemCell.self, indexPath: indexPath)
			cell.configure(enable: false)
			let item = interactor.dataSource.dataInputComplaint
			cell.mainButton.isValid = item == nil ? false : true
			
			cell.handler = { [weak self] in
				guard let self = self else { return }
				if item != nil {
					guard let input = self.interactor.dataSource.dataInputComplaint else {
						return
					}
					self.interactor.doRequest(.inputComplaint(data: input))
				}
			}
			
			return cell
		default:
			return UITableViewCell()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.row {
				case 6:
					if self.isSelect {
						return 140
					} else {
						return 20
					}
        case 8:
            return 120
        case 9:
            return 80
		default:
			return 70
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		switch row {
		case 0, 1, 2, 3, 4:
			self.interactor.dataSource.reason = reasonComplaint[row]
			print("selected \(interactor.dataSource.reason)")
			self.isSelect = false
			tableView.beginUpdates()
			tableView.endUpdates()
		case 5:
				self.interactor.dataSource.reason = reasonComplaint[row]
				print("selected \(interactor.dataSource.reason)")
			self.isSelect = true
			tableView.beginUpdates()
			tableView.endUpdates()
		default:
			break
		}
	}
}

extension ComplaintController {
	
	func showPicker(_ index: Int) {
        self.present(imagePickerController, animated: true)
        imagePickerController.handleMediaSelected = { [weak self] (media) in
            guard let self = self else { return }
            self.hud.show(in: self.view)
            
            switch media.type {
            case .photo:
                self.interactor.doRequest(.uploadPhoto(media))
            case .video:
                self.interactor.doRequest(.uploadVideo(media))
            }
        }
	}
}


// MARK: - Private Zone
private extension ComplaintController {
	
	func displayComplaint(_ viewModel: DefaultResponse) {
		router.routeTo(.confirmComplaint)
	}
	
	func responseUpload(_ viewModel: ResponseMedia) {
		interactor.dataSource.media = viewModel
		interactor.dataSource.dataInputComplaint = ComplaintInput(
			orderId: interactor.dataSource.id,
			reason: interactor.dataSource.reason,
			evidenceVideoUrl: viewModel.url ?? ""
		)
		mainView.tableView.reloadData()
		hud.dismiss()
	}
	
	func presentError(_ error: ErrorMessage?){
		displayAlert(with: "\(error?.statusCode ?? 0) Error", message: "\(error?.statusMessage ?? "Something Went Wrong, Try again later")", actions: [UIAlertAction(title: "OK", style: .default)])
	}

}
