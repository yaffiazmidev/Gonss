////
////  VCPreviewFotoVideo.swift
////  AppVideo
////
////  Created by Icon+ Gaenael on 16/02/21.
////
//
import UIKit
//import AVKit
//import Combine
//
//class VCPreviewFotoVideo: UIViewController {
//
//	private let imgView = UIImageView()
//	private let btnClose   = UIButton(type: .system)
//	private let btnAddProduct = UIButton(type: .system)
//	private let btnAddStory   = UIButton(type: .system)
//
//	var image : UIImage?
//	var data  : Data?
//	var path  : String?
//    var product: Product?
//	var actionDismiss : (Product? ,UIImage?, Data?) -> () = { _, _, _ in }
//
//	private var subscriptions = Set<AnyCancellable>()
//	private let network = UploadNetworkModel()
//	private var consWidthButton = NSLayoutConstraint()
//	private let cell = Bundle.main.loadNibNamed("RowTagProduct", owner: self, options: nil)?[0] as! RowTagProduct
//	private var selected : Product?
//	private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		// Do any additional setup after loading the view.
//		setupView()
//		fetchDataProduct("")
//		if let _ = path{
//			setVideo()
//		}
//	}
//}
//
//extension VCPreviewFotoVideo{
//
//	private func setupView(){
//		view.backgroundColor = .black
//		imgView.translatesAutoresizingMaskIntoConstraints = false
//		imgView.image = image
//		imgView.contentMode = .scaleAspectFit
//		view.addSubview(imgView)
//
//		btnClose.addTarget(self, action: #selector(actionClose), for: .touchUpInside)
//		btnClose.setImage(UIImage(systemName: "xmark"), for: .normal)
//		btnClose.tintColor = .white
//		btnClose.translatesAutoresizingMaskIntoConstraints = false
//		view.addSubview(btnClose)
//
//		btnAddProduct.translatesAutoresizingMaskIntoConstraints = false
//		btnAddProduct.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//		btnAddProduct.setTitle("Tag Product", for: .normal)
//		btnAddProduct.setTitleColor(.white, for: .normal)
//		btnAddProduct.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//		btnAddProduct.layer.cornerRadius = 20
//		btnAddProduct.isHidden = true
//		btnAddProduct.addTarget(self, action: #selector(actionAddProduct), for: .touchUpInside)
//		view.addSubview(btnAddProduct)
//
//		let lblMyStory = UILabel()
//		lblMyStory.text = "My Story"
//		lblMyStory.textColor = .white
//		lblMyStory.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
//		lblMyStory.sizeToFit()
//
//		btnAddStory.backgroundColor = UIColor.orange
//		btnAddStory.layer.cornerRadius = 20
//		btnAddStory.setImage(UIImage(systemName: "plus"), for: .normal)
//		btnAddStory.tintColor = .white
//		btnAddStory.addTarget(self, action: #selector(actionAddStory), for: .touchUpInside)
//
//		let vStack = UIStackView(arrangedSubviews: [lblMyStory,btnAddStory])
//		vStack.axis = .vertical
//		vStack.spacing = 8
//		vStack.alignment = .center
//		vStack.translatesAutoresizingMaskIntoConstraints = false
//		view.addSubview(vStack)
//
//		cell.contentView.isHidden = true
//		cell.setupMargin(12)
//		cell.contentView.translatesAutoresizingMaskIntoConstraints = false
//		cell.contentView.backgroundColor = .white
//		cell.contentView.layer.cornerRadius = 12
//		cell.isHidden = true
//		view.addSubview(cell.contentView)
//
//		consWidthButton = btnAddProduct.widthAnchor.constraint(equalToConstant: 120)
//		NSLayoutConstraint.activate([
//			imgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//			imgView.topAnchor.constraint(equalTo: view.topAnchor),
//			imgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//			imgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//			btnClose.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//			btnClose.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
//			btnClose.widthAnchor.constraint(equalToConstant: 32),
//			btnClose.heightAnchor.constraint(equalToConstant: 32),
//			btnAddProduct.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//			btnAddProduct.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
//			consWidthButton,
//			btnAddProduct.heightAnchor.constraint(equalToConstant: 40),
//			btnAddStory.heightAnchor.constraint(equalToConstant: 40),
//			btnAddStory.widthAnchor.constraint(equalToConstant: 40),
//			vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//			vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
//			cell.contentView.bottomAnchor.constraint(equalTo: vStack.topAnchor, constant: -24),
//			cell.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//			cell.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
//		])
//
//        if let prod = self.product {
//            setProductFromShareAsProduct(prod: prod)
//        }
//	}
//
//	private func setVideo(){
//		imgView.isHidden = true
//		let player = AVPlayer(url: URL(fileURLWithPath: path ?? ""))
//		let playerLayer = AVPlayerLayer(player: player)
//		playerLayer.frame = self.view.bounds
//		self.view.layer.insertSublayer(playerLayer, at: 0)
//		player.play()
//	}
//
//}
//
//extension VCPreviewFotoVideo{
//
//	@objc private func actionAddProduct(){
//		let vc = VCProduct()
//		vc.actionSelect = { prod in
//			self.selected = prod
//			self.btnAddProduct.setTitle("Change Product", for: .normal)
//			self.consWidthButton.constant = 144
//			self.cell.contentView.isHidden = false
//			self.cell.setupData(prod)
//			self.cell.btnDelete.isHidden = false
//			self.cell.onCloseClick = {
//				self.cell.contentView.isHidden = true
//				self.btnAddProduct.setTitle("Tag Product", for: .normal)
//			}
//		}
//		vc.modalPresentationStyle = .fullScreen
//		vc.modalTransitionStyle  = .crossDissolve
//		self.present(vc, animated: true, completion: nil)
//	}
//
//	@objc private func actionClose(){
//		self.dismiss(animated: true, completion: nil)
//	}
//
//	@objc private func actionAddStory(){
//        if product != nil {
//            uploadPhoto()
//        } else {
//            self.dismiss(animated: true, completion: {
//                self.actionDismiss(self.selected, self.image, self.data)
//            })
//        }
//
////		if let p = data{
////			uploadVideo(p)
////		}
////		else{
////			uploadPhoto()
////		}
//	}
//
//}
//
//
////MARK:: API - Upload Photo, Video And Create Story
//extension VCPreviewFotoVideo{
//	private func uploadPhoto() {
//		hud.show(in: view)
//
//		network.processedUploadPhoto(image: self.image!, .uploadMedia(imagePath: "", ratio: "1:1")) { result in
//
//			switch result {
//			case .success(let media):
//				self.postStory(media)
//			case .failure(let error): print(error?.localizedDescription as Any)
//			}
//		}
//
//	}
//
//	private func uploadVideo(_ d: Data) {
//		hud.show(in: view)
//
//		network.processedUploadVideo(video: d, .uploadMedia(imagePath: "", ratio: "1:1")) { result in
//
//			switch result {
//			case .failure(let error):
//				self.showAlert(error?.localizedDescription ?? "", "Error upload video")
//			case .success(let media):
//				self.postStory(media)
//			}
//		}
//	}
//
//	private func postStory(_ media: ResponseMedia) {
//
//		let productIds = [MediaPostProductId(id: self.selected?.id ?? "")]
//		self.postCreateStory(media, productIds)
//	}
//
//	func postCreateStory(_ media: ResponseMedia, _ product: [MediaPostProductId]?){
//		let param = MediaPostStory(medias: [media], postProducts: product)
//		let validParameter = ParameterPostStory(post: [param], typePost: "story")
//		network.createStory(.createStory, validParameter) { result in
//
//			switch result {
//			case .failure(let error):
//				DispatchQueue.main.async {
//					self.showAlert(error?.localizedDescription ?? "", "Error post story")
//				}
//			case .success:
//				DispatchQueue.main.async {
//					self.dismiss(animated: true, completion: {
//                        self.actionDismiss(self.product, self.image, self.data)
//					})
//				}
//			}
//		}
//	}
//
//	private func showAlert(_ title: String,
//												 _ msg: String){
//		UIAlertController.showAlertWithOneButton(title, msg, .alert, "Close", { _ in
//			self.dismiss(animated: true) {
////				self.actionDismiss()
//			}
//		}, self)
//	}
//}
//
extension UIAlertController {
	static func showAlertWithOneButton(_ title  : String,
																		 _ msg    : String,
																		 _ style  : UIAlertController.Style,
																		 _ btn_name : String,
																		 _ completion: ((UIAlertAction) -> Void)? = nil,
																		 _ control: UIViewController){
		
		let action = UIAlertAction(title: btn_name, style: .cancel, handler: completion)
		let alert  = UIAlertController(title: title, message: msg, preferredStyle: style)
		alert.addAction(action)
		control.present(alert, animated: true, completion: nil)
	}
}


//extension VCPreviewFotoVideo {
//    func setProductFromShareAsProduct(prod : Product){
//        self.selected = prod
//        self.btnAddProduct.setTitle("Change Product", for: .normal)
//        self.consWidthButton.constant = 144
//        self.cell.contentView.isHidden = false
//        self.cell.setupData(prod)
//        self.cell.btnDelete.isHidden = false
//        self.cell.onCloseClick = {
//            self.cell.contentView.isHidden = true
//            self.btnAddProduct.setTitle("Tag Product", for: .normal)
//        }
//    }
//
//	private func fetchDataProduct(_ key: String){
//		let network = ProductNetworkModel()
//
//		let userId = getIdUser()
//		network.searchMyProducts(.searchListProductById(id: userId, text: key)).sink { completion in
//			switch completion {
//			case .failure:
//				self.btnAddProduct.isHidden = true
//			case .finished: break
//			}
//			} receiveValue: { model in
//				if let data = model.data?.content {
//					if data.isEmpty {
//							self.btnAddProduct.isHidden = true
//					} else {
//							self.btnAddProduct.isHidden = false
//					}
//				} else {
//						self.btnAddProduct.isHidden = false
//				}
//			}.store(in: &subscriptions)
//	}
//}
//
//
//extension VCPreviewFotoVideo {
//    func setProductFromShareAsProduct(prod : Product){
//        self.selected = prod
//        self.btnAddProduct.setTitle("Change Product", for: .normal)
//        self.consWidthButton.constant = 144
//        self.cell.contentView.isHidden = false
//        self.cell.setupData(prod)
//        self.cell.btnDelete.isHidden = false
//        self.cell.onCloseClick = {
//            self.cell.contentView.isHidden = true
//            self.btnAddProduct.setTitle("Tag Product", for: .normal)
//        }
//    }
//
//	private func fetchDataProduct(_ key: String){
//		let network = ProductNetworkModel()
//
//		let userId = getIdUser()
//		network.searchMyProducts(.searchListProductById(id: userId, text: key)).sink { completion in
//			switch completion {
//			case .failure:
//				self.btnAddProduct.isHidden = true
//			case .finished: break
//			}
//			} receiveValue: { model in
//				if let data = model.data?.content {
//					if data.isEmpty {
//							self.btnAddProduct.isHidden = true
//					} else {
//							self.btnAddProduct.isHidden = false
//					}
//				} else {
//						self.btnAddProduct.isHidden = false
//				}
//			}.store(in: &subscriptions)
//	}
//}
