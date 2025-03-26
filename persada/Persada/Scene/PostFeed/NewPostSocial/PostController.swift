//
//  PostController.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

protocol PostDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: PostModel.ViewModel)
}

protocol PostControllerDelegate {
	func setChannel(channel: Channel)
}

protocol PostControllerType : UIViewController {
    func reloadMediaCollectionView(_ medias: [KKMediaItem])
}

final class PostController: UIViewController, PostControllerType, Displayable, PostDisplayLogic, PostViewDelegate, AlertDisplayer, UITableViewDelegate, UITableViewDataSource {
 
    
	
	let mainView: PostView
	var interactor: PostSocialInteractable!
	var router: PostRouting!
  
    private let disposeBag = DisposeBag()
    private let addressUsecase = Injection.init().provideAddressUseCase()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
	
	var videoURL: [String] = []
	var selectedItem = [UIImage]()
	var imageURL: [String] = []
	var isLoading: Bool = false
	var isMediaAvailable = false
	var indexCollection = 0
    var switchIsOn = false
    var addressIsAdded = false
    var isTiktok = false
	var isTagProduct = false
    var isShareProductAsPost = false
    
    var onPostClickCallback : (PostFeedParam) -> () = { _ in }
    
    private var listener: MentionListener?
    private var filterString: String = ""
    private var mentions: [FeedCommentMentionEntity] = []
    
    private var mentionsList: [FeedCommentMentionEntity] {
        guard !mentions.isEmpty, filterString != "" else { return [] }
        let keyword = filterString.lowercased()
        return mentions
            .filter { $0.slug.contains(keyword) }
            .sorted { ($0.slug.hasPrefix(keyword) ? 0 : 1) < ($1.slug.hasPrefix(keyword) ? 0 : 1) }
    }
    
    private let mentionAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: UIColor.systemBlue),
        Attribute(name: .font, value: UIFont(name: "Roboto-Bold", size: 12)!),
    ]
    
    private let defaultAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)),
        Attribute(name: .font, value: UIFont(name: "Roboto-Regular", size: 12)!),
    ]
    
	init(mainView: PostView, dataSource: PostModel.DataSource) {
		self.mainView = mainView
		super.init(nibName: nil, bundle: nil)
		interactor = PostInteractor(viewController: self, dataSource: dataSource)
		router = PostRouter(self)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		tabBarController?.tabBar.isHidden = false
		navigationController?.navigationBar.backgroundColor = nil
        print("PostController - viewWillDisappear : \(switchIsOn)")
        NotificationCenter.default.removeObserver(self, name:  UIApplication.didBecomeActiveNotification, object: nil)
    
	}
	
	override func loadView() {
		self.view = mainView
		self.view.backgroundColor = .white
		mainView.delegate = self
		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self
        
        mainView.mentionTableView.delegate = self
        mainView.mentionTableView.dataSource = self
        let mentionsListener = MentionListener(mentionsTextView: mainView.captionCTV.nameTextField,
                                               mentionTextAttributes: { _ in self.mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: true,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString)
        mainView.captionCTV.nameTextField.delegate = mentionsListener
        listener = mentionsListener
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		self.setupNavBarItem()
        self.enableRightBarButton()
        self.fetchAddressDelivery()
        self.addNotifObserverWhenAppEnterForeground()
        
        [mainView.nameItemView, mainView.priceItemView, mainView.lengthTextInput, mainView.widthTextInput, mainView.heightTextInput, mainView.weightTextInput].forEach { textField in
            textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        }
        
        self.mainView.priceItemView.rx.controlEvent(.editingChanged)
            .asObservable()
            .withLatestFrom(self.mainView.priceItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.priceItemView.text = text.digits().toMoney()
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.stockItemView.rx.controlEvent(.editingChanged)
            .asObservable()
            .withLatestFrom(self.mainView.stockItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.stockItemView.text = text
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.nameItemView.rx.controlEvent(.editingChanged)
            .asObservable()
            .withLatestFrom(self.mainView.nameItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.labelLengthProductName.text = "\(text.count)/70"
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        
        
        mainView.weightTextInput.rx.controlEvent(.editingChanged)
            .asObservable()
            .withLatestFrom(mainView.weightTextInput.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.weightTextInput.text = text.replacingOccurrences(of: ",", with: ".")
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.captionCTV.nameTextField.rx.didChange
            .asObservable()
            .withLatestFrom(self.mainView.captionCTV.nameTextField.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.enableRightBarButton()
                guard let count = self?.mainView.captionCTV.nameTextField.text.count else { return }
                
                if count == 1 {
                    if self?.mainView.captionCTV.nameTextField.text.first == " " {
                        self?.mainView.captionCTV.nameTextField.text = ""
                        return
                    }
                }
                if let tiktok = self?.isTiktok {
                    if tiktok {
                        self?.mainView.labelLengthCaption.text = "\(count)/150"
                        return
                    }
                }
                self?.mainView.labelLengthCaption.text = "\(count)/1000"
            })
            .disposed(by: disposeBag)
        
        mainView.onSwitchAsProductChange = { switchOn in
            if self.addressIsAdded && !getEmail().isEmpty {
                if switchOn {
                    self.switchIsOn = true
                    self.mainView.showView()
                    self.enableRightBarButton()
                    return
                }
                self.switchIsOn = false
                self.enableRightBarButton()
                self.mainView.hideView()
            } else {
                self.displayAlert(with: .get(.tokoKamuBelumSiap), message: .get(.tokoBelumSiapDesc) + "\n\n" + .get(.tokoProfileShop), actions: [UIAlertAction(title: "Close", style: .cancel, handler: nil)])
                self.mainView.postProductCSWL.isChecked = false
                self.mainView.hideView()
                return
            }
          
        }
        mainView.floatingTitleField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe { [weak self] (text) in
                self?.enableRightBarButton()
            }
        
        mainView.floatingLinkField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe { [weak self] (text) in
                self?.enableRightBarButton()
            }
	}
    
    private func hideMentions() {
        filter("")
    }
    
    private func didHandleMentionOnReturn() -> Bool { return false }
    
    private func showMentionsListWithString(mentionsString: String, trigger _: String) {
        filter(mentionsString)
    }
    
    private func filter(_ string: String) {
        if let caption = mainView.captionCTV.nameTextField.text , caption.count >= (isTiktok ? 150 : 1000) {
            mainView.captionCTV.nameTextField.text = String(caption.prefix(isTiktok ? 150 : 1000))
            return
        }
        
        searchAccount(text: string)
        filterString = string
        mainView.captionCTV.placeholderLabel.isHidden = !mainView.captionCTV.nameTextField.text.isEmpty
    }
    
    private func searchAccount(text: String) {
        guard !text.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mainView.mentionTableView.isHidden = true
                self.view.layoutIfNeeded()
            }
            return
        }
        
        let request = ProfileEndpoint.searchFollowers(id: getIdUser(), name: text, page: 0)
        Injection.init().provideProfileUseCase().searchAccount(request: request)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                guard let code = result.code, code == "1000" else {
                    print("Not found!")
                    return
                }
                
                let result = result.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                self.mentions = result ?? []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.mainView.mentionTableView.reloadData()
                    self.mainView.mentionTableView.isHidden = self.mentions.count <= 0
                }
            } onError: { error in
                print(error.localizedDescription)
                self.mainView.mentionTableView.isHidden = self.mentions.isEmpty
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.addMention(mentionsList[indexPath.row])
        mainView.mentionTableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { mentionsList.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCellTableViewCell", for: indexPath) as! MentionCellTableViewCell
        let mention = mentionsList[indexPath.row]
        cell.backgroundColor = .white
        cell.nameLabel.textColor = .black
        cell.nameLabel.text = String(mention.name.dropFirst())
        cell.usernameLabel.text = mention.fullName
        cell.pictureImageView.loadImage(at: mention.photoUrl)
        return cell
    }
    
    func addNotifObserverWhenAppEnterForeground(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.whenAppEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func whenAppEnterForeground(_ notification: Notification)  {
        if notification.name == UIApplication.didBecomeActiveNotification{
            if switchIsOn {
                self.mainView.showView()
            }else{
                self.mainView.hideView()
            }
        }
    }
    
    func fetchAddressDelivery(){
        addressUsecase.getAddressDelivery(accountID: getIdUser())
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { (address) in
                if address.data != nil {
                    self.addressIsAdded = true
                }
            } onError: { (error) in
                self.addressIsAdded = false
            }.disposed(by: disposeBag)

    }
    
    @objc
    func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
       enableRightBarButton()
    }
	
	func reloadMediaCollectionView(_ medias: [KKMediaItem]) {
        self.interactor.dataSource.itemMedias = medias
        mainView.collectionView.reloadData()
        enableRightBarButton()
	}
	
    private func deleteUnitCm(_ str: String) -> Double {
        let str = str.replacingOccurrences(of: ",", with: ".")
        return str.suffix(3) == " cm" ? Double(str.dropLast(3))! : Double(str) ?? 0.0
    }
    
    private func deleteUnitKg(_ str: String) -> Double {
        let str = str.replacingOccurrences(of: ",", with: ".")
        return str.suffix(3) == " kg" ?  Double(str.dropLast(3))!: 0
    }
	
	@objc func handlePostButtton() {
        let captionText = mainView.captionCTV.nameTextField.text ?? ""
        navigationItem.rightBarButtonItem?.isEnabled = false
        var postFeedParam : PostFeedParam? = nil
        let mediaSource = interactor.dataSource.itemMedias
        let channelID = ChannelParam(id: interactor.dataSource.channel?.id ?? nil)
        var media : [KKMediaItem] = []
        if isTiktok {
            if let source = mediaSource?.first {
                media.append(source)
            }
        } else {
            if let source = mediaSource {
                media = source
            }
        }
        
        let validFloatingLink = validFloatingLink(text: mainView.floatingLinkField.text)    
                
        if switchIsOn {
            guard let weight = self.mainView.weightTextInput.text else { return }
            var weightDouble : Double = 0.0
            if weight.containsIgnoringCase(find: "Kg") {
                weightDouble = deleteUnitKg(self.mainView.weightTextInput.text ?? "0")
            } else {
                weightDouble = Double(weight) ?? 0.0
            }
            
            let measurement = ProductMeasurement(weight: weightDouble,
                                                 length: deleteUnitCm( self.mainView.lengthTextInput.text ?? "0"),
                                                 height: deleteUnitCm(self.mainView.heightTextInput.text ?? "0"),
                                                 width: deleteUnitCm(self.mainView.widthTextInput.text ?? "0"))
            
            let price = mainView.priceItemView.text?.digits()
            let stock = Int(mainView.stockItemView.text ?? "0")
            let desc = captionText.count == 0 ? "-" : captionText
            let product = ProductParam(id: "", measurement: measurement, description: desc, name: mainView.nameItemView.text ?? "", price:  price?.toDouble() ?? 0, stock: stock ?? 0)
            let post = PostFeed(postDescription: captionText, responseMedias: nil, itemMedias: media, product: product, channel: channelID, type: "social", floatingLink: validFloatingLink, floatingLinkLabel: mainView.floatingTitleField.text)
            postFeedParam?.typePost = "social"
            postFeedParam = PostFeedParam(post: post, typePost: "social")
            triggerPostCallback(postFeedParam: postFeedParam)
            return
        }
        
        if isTagProduct {
            let productSource = interactor.dataSource.product
            guard let measurement = productSource?.measurement else { return }
            let product = ProductParam(id: productSource?.id ?? "", measurement: measurement, description: productSource?.postProductDescription ?? "", name: productSource?.name ?? "", price:  productSource?.price ?? 0.0, stock: productSource?.stock ?? 0)
            let post = PostFeed(postDescription: captionText, responseMedias: nil, itemMedias: media, product: product, channel: channelID, type: "social", floatingLink: validFloatingLink, floatingLinkLabel: mainView.floatingTitleField.text)
            postFeedParam?.typePost = "social"
            postFeedParam = PostFeedParam(post: post, typePost: "social")
            triggerPostCallback(postFeedParam: postFeedParam)
            return
        }
        
        let post = PostFeed(postDescription: mainView.captionCTV.nameTextField.text, responseMedias: nil, itemMedias: media, product: nil, channel: channelID, type: "social",
                            floatingLink: validFloatingLink,
                            floatingLinkLabel: mainView.floatingTitleField.text)
        postFeedParam = PostFeedParam(post: post, typePost: "social")
        triggerPostCallback(postFeedParam: postFeedParam)
	}
    
    func validFloatingLink(text : String?) -> String? {
        guard let text = text else { return nil }
        
        guard let validURL = URL(string: text) else {
            return nil
        }
        
        guard validURL.absoluteString.hasPrefix("https://") || validURL.absoluteString.hasPrefix("http://") else {
            return "https://" + validURL.absoluteString
        }
        
        return validURL.absoluteString
    }


    func triggerPostCallback(postFeedParam : PostFeedParam?){
        if let post = postFeedParam {
            onPostClickCallback(post)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                guard let viewControllers = self.navigationController?.viewControllers else {
                    return
                }

//                for firstViewController in viewControllers {
//                    
//                    if firstViewController is YPPickerVC {
//                        let vc = firstViewController as? YPPickerVC
//                        vc?.isDismiss = true
//                        vc?.dismissAnimation = false
//                        self.navigationController?.popToViewController(firstViewController, animated: true)
//                        break
//                    }
//                }
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

	// MARK: - PostDisplayLogic
	func displayViewModel(_ viewModel: PostModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
			case .media(let viewModel):
				self.responseUpload(viewModel)
			case .post(let viewModel):
				self.responsePostSocial(viewModel)
			case .error(let error):
				self.presentError(error)
			}
		}
	}

    func showPicker(_ index: Int) {
        showCamerasViewController?({ [weak self] item in
            guard let self = self else { return }
            
            DispatchQueue.global(qos: .background).async {
                self.interactor.dataSource.itemMedias!.append(item)
            }
            
            self.mainView.collectionView.reloadData()
            self.enableRightBarButton()
            if self.isShareProductAsPost {
                self.mainView.productSelectedView.isHidden = false
                self.mainView.postProductCSWL.isHidden = true
                
            }
        })
	}
	
	var documentsUrl: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	
	private func load(fileName: String) -> UIImage? {
		let fileURL = documentsUrl.appendingPathComponent(fileName)
		
		do {
			let imageData = try Data(contentsOf: fileURL)
			return UIImage(data: imageData)
		} catch {
			print("Error loading image : \(error)")
		}
		return nil
	}
    
    func enableRightBarButton() {
        let floatingTitleEmpty = mainView.floatingTitleField.text.isNilOrEmpty
        let floatingLinkEmpty = mainView.floatingLinkField.text.isNilOrEmpty
        if (!floatingLinkEmpty || !floatingTitleEmpty) && (floatingLinkEmpty || floatingLinkEmpty) { // this is XNOR Logic Gate
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        let floatingTitleHasError = !mainView.floatingTitleErrorLabel.isHidden
        let floatingLinkHasError = !mainView.floatingLinkErrorLabel.isHidden
        
        if floatingTitleHasError || floatingLinkHasError {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        guard !switchIsOn else {
            postAsProductValidation()
            return
        }
        
        guard let count = interactor.dataSource.itemMedias, !count.isEmpty else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func postAsProductValidation() {
        let isValidLength = mainView.lengthTextInput.text?.isEmpty == true || mainView.lengthTextInput.isValidDimention()
        let isValidWidth  = mainView.widthTextInput.text?.isEmpty == true || mainView.widthTextInput.isValidDimention()
        let isValidHeight = mainView.heightTextInput.text?.isEmpty == true || mainView.heightTextInput.isValidDimention()
        mainView.lengthTextInput.setBorderColor = isValidLength ? .whiteSmoke : .warning
        mainView.widthTextInput.setBorderColor = isValidWidth ? .whiteSmoke : .warning
        mainView.heightTextInput.setBorderColor = isValidHeight ? .whiteSmoke : .warning
        
        
        guard let weight = Double(mainView.weightTextInput.text?.replacingOccurrences(of: " kg", with: "") ?? "") else {
            mainView.labelWeightError.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        guard weight >= 0.1 else {
            mainView.labelWeightError.isHidden = false
            mainView.labelWeightError.text = .get(.minimalBerat01)
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        guard weight <= 50.0 else {
            mainView.labelWeightError.isHidden = false
            mainView.labelWeightError.text = .get(.maksimalBerat50)
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        mainView.labelWeightError.isHidden = true
        
        guard
            let count = interactor.dataSource.itemMedias, !count.isEmpty,
            let name = mainView.nameItemView.text, !name.isEmpty,
            let price = mainView.priceItemView.text, !price.isEmpty && price.prefix(4) != "Rp 0",
            let stock = mainView.stockItemView.text, !stock.isEmpty && stock != "0"
        else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = mainView.lengthTextInput.isValidDimention() && mainView.widthTextInput.isValidDimention() && mainView.heightTextInput.isValidDimention()
    }
}

extension UITextField {
    func isValidDimention() -> Bool {
        let dimention = self.text?.digits() ?? "0.0"
        return dimention.first != "0" && !dimention.isEmpty
    }
}

extension PostController: PopUpTextViewControllerDelegate {
    func textView(result: String) {
        mainView.captionCTV.placeholderLabel.isHidden = !result.isEmpty
        mainView.captionCTV.nameTextField.text = result
        let captionCTV = mainView.captionCTV.nameTextField.text
        
        if captionCTV?.count == 1 {
            if captionCTV?.first == " " {
                mainView.captionCTV.nameTextField.text = ""
                return
            }
        }
        
        if isTiktok {
            mainView.labelLengthCaption.text = "\(captionCTV?.count ?? 0)/150"
            return
        }
        
        mainView.labelLengthCaption.text = "\(captionCTV?.count ?? 0)/1000"
    }
}

extension PostController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChangeMedia {
	
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let totalImages = self.interactor.dataSource.itemMedias!.count
		
		if totalImages == 5 {
			return 5
		}
        
        if isTiktok {
            return 1
        }
		
		return totalImages + 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: PostItemCell.self, indexPath: indexPath)
		let row = indexPath.row
		
        let totalImages = self.interactor.dataSource.itemMedias!.count
		
		if totalImages != 0 && row <= totalImages {
			if row < totalImages {
                let sourceFile = interactor.dataSource.itemMedias![row]
                switch sourceFile.type {
                case .photo:
                    cell.imageView.image = UIImage(data: sourceFile.data!)
                    cell.iconView.isHidden = true
                case .video:
                    cell.imageView.image = sourceFile.videoThumbnail
                    cell.iconView.isHidden = false
                    cell.iconView.image = UIImage(named: AssetEnum.iconPlay.rawValue)
                }
                
			} else {
				cell.imageView.image = UIImage(named: .get(.btnAddMedia))
                cell.iconView.isHidden = true
			}
		} else {
			cell.imageView.image = UIImage(named: .get(.btnAddMedia))
            cell.iconView.isHidden = true
		}
		
        cell.handleMedia = {
            self.indexCollection = row
            let medias = self.interactor.dataSource.itemMedias!
            
            var uiImages: [UIImage] = []
            for item in medias {
                if item.type == .video {
                    uiImages.append(item.videoThumbnail!)
                }else {
                    uiImages.append(UIImage(data: item.data!)!)
                }
            }
            if self.interactor.isMediaAvailable(row,uiImages) {
                let media = self.interactor.dataSource.responseMedias
                self.router.routeTo(.preview(row, medias , media!))
            } else {
                self.showPicker(self.indexCollection)
            }
            
        }
        
        return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = view.frame.width / 5 - 16
		return CGSize(width: size , height: size)
	}
	
	func removeMedia(_ index: Int) {
		interactor.removeMedia(index)
	}
}

// MARK: - Private Zone
private extension PostController {
	
	func responseUpload(_ viewModel: ResponseMedia) {
		interactor.saveMedia(viewModel)
		self.mainView.collectionView.reloadData()
		hud.dismiss()
	}
	
	func responsePostSocial(_ viewModel: DefaultResponse) {
		hud.dismiss()
		router.routeTo(.dismiss)
	}
	
	func presentError(_ error: ErrorMessage?){
        hud.dismiss()
		displayAlert(with: "\(error?.statusCode ?? 0) Error", message: error?.statusMessage ?? .get(.errorDefault), actions: [UIAlertAction(title: .get(.ok), style: .cancel)])
	}
	
	func setupNavBarItem() {
		let rightBarButton = UIBarButtonItem(title: .get(.post), style: .plain, target: self, action: #selector(handlePostButtton))
		rightBarButton.tintColor = .primary
		let leftBarButton = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(handleBackButton))
        rightBarButton.isEnabled = false
		navigationItem.title = .get(.settingPosting)
		navigationItem.rightBarButtonItem = rightBarButton
		navigationItem.leftBarButtonItem = leftBarButton
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 12)]
	}
	
	
	@objc func handleBackButton() {
        if isShareProductAsPost {
            router.routeTo(.back)
        } else {
            router.routeTo(.dismiss)
        }
	}
	
}

extension PostController : PostControllerDelegate {
	func setChannel(channel: Channel) {
		interactor.dataSource.channel = channel
		
        if channel.code?.uppercased() == "TIKTOK" {
            let lanjutkanAction = UIAlertAction(title: .get(.lanjutkan), style: .default) { action in
                self.isTiktok = true
                self.mainView.collectionView.reloadData()
                self.mainView.handleTiktokView()
            }
            let kembaliAction = UIAlertAction(title: .get(.back), style: .cancel) { action in
                self.interactor.dataSource.channel = nil
                self.isTiktok = false
                self.mainView.channelSelectedView.isHidden = true
                self.mainView.channelButtonSelectView.isHidden = false
                self.router.routeTo(.chooseChannel)
            }
            
            self.displayAlert(with: "", message: .get(.tikTokAlertDesc), actions: [lanjutkanAction, kembaliAction])
        } else if isTiktok && channel.code?.uppercased() != "TIKTOK" {
                self.isTiktok = false
                self.mainView.reverseTiktokView()
                self.mainView.collectionView.reloadData()
        }
        
        mainView.setSelectedChannel(channel: channel) {
            self.interactor.dataSource.channel = nil
            if self.isTiktok {
                self.isTiktok = false
                self.mainView.reverseTiktokView()
                self.mainView.collectionView.reloadData()
            }
        }
	}
	
	func whenChannelClicked() {
		router.routeTo(.chooseChannel)
	}
	
	func changeType(type: String) {
		interactor.changeType(type)
	}
    
    func whenTagProductClicked() {
        let vc = VCProduct()
        vc.isFromPost = true
        vc.actionSelect = { prod in
            self.isTagProduct = true
            self.interactor.dataSource.product = prod
            self.mainView.setSelectedProduct(product: prod) { [weak self] in
                self?.interactor.dataSource.product = nil
                self?.isTagProduct = false
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
	
    func shareAsProductHandler(product : Product){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTagProduct = true
            self.interactor.dataSource.product = product
            self.mainView.setSelectedProduct(product: product) { [weak self] in
                self?.interactor.dataSource.product = nil
                self?.isTagProduct = false
            }
        }
      
    }
}

extension PostController{
    private func refreshData(_ images: [KKMediaItem]){
//        var data_media : [YPMediaItem] = []
//        interactor.dataSource.medias!.forEach { item in
//            switch item {
//            case .photo(let photo):
//                if let _ = images.filter({$0.asset == photo.asset}).first{
//                    data_media.append(item)
//                }
//            case .video(let video):
//                if let _ = images.filter({$0.asset == video.asset}).first{
//                    data_media.append(item)
//                }
//            }
//        }
        interactor.dataSource.itemMedias = images
    }
}
