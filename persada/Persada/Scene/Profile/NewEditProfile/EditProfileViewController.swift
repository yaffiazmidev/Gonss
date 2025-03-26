//
//  EditProfileViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import KipasKipasShared

protocol EditProfileDisplayLogic where Self: UIViewController {

	func displayViewModel(_ viewModel: EditProfileModel.ViewModel)
}

class EditProfileViewController: UIViewController, Displayable, EditProfileDisplayLogic, AlertDisplayer {

	private let mainView: EditProfileView
	private var interactor: EditProfileInteractable!
	private var router: EditProfileRouting!
    private lazy var saveButton = UIBarButtonItem(title: "Simpan", style: .plain, target: self, action: #selector(self.saveItem))

    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))

	required init(mainView: EditProfileView, dataSource: EditProfileModel.DataSource) {
		self.mainView = mainView

		super.init(nibName: nil, bundle: nil)
		interactor = EditProfileInteractor(viewController: self, dataSource: dataSource)
		router = EditProfileRouter(self)
	}
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
	override func viewDidLoad() {
		super.viewDidLoad()
		interactor.doRequest(.getProfile(id: interactor.dataSource.id))
	}

	override func loadView() {
		view = mainView
		view.backgroundColor = .white
		mainView.delegate = self
		setupNav()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}


	// MARK: - EditProfileDisplayLogic
	func displayViewModel(_ viewModel: EditProfileModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {

				case .getProfile(let viewModel):
					self.displayGetProfile(viewModel)
				case .uploadImage(let viewModelData):
					self.displayResponseUploadImage(viewModelData)
				case .updateProfile(data: let data):
					self.displayUpdateProfile(data)
			}
		}
	}
}


// MARK: - EditProfileViewDelegate
extension EditProfileViewController: EditProfileViewDelegate, EditProfileViewDataSource {
	func whenUploadButtonClicked() {
        showCameraPhotoViewController?({ [weak self] media in
            guard let self = self, let data = media.data, let image = UIImage(data: data) else { return }

            self.saveButton.isEnabled = false
            self.mainView.profilePhotoImageView.image = image.withRenderingMode(.alwaysOriginal)
            self.interactor.doRequest(.uploadImage(item: media))
            self.hud.show(in: self.view)
        })
	}
}


// MARK: - Private Zone
private extension EditProfileViewController {

	func displayGetProfile(_ viewModel: ResultData<EditProfileResult>) {
		switch viewModel {
			case .success(let data):
				if let image = data.data?.photo {
					var photo = image
					
					interactor.doRequest(.updateUploadedImageUrl(source: photo))
				}
				mainView.updateProfile(data.data)
			case .failure(let err):
				let action = UIAlertAction(title: "OK", style: .default)
                self.displayAlert(with: "Warning" , message: err?.statusData ?? "", actions: [action])
		}
		hud.dismiss()
	}

	func displayUpdateProfile(_ viewModel: ResultData<DefaultResponse>) {
		switch viewModel {
			case .success(_):
				router.routeTo(.dismissWhenAlreadySave)
			case .failure(let err):
				let action = UIAlertAction(title: "OK", style: .default)
                self.displayAlert(with: "Warning" , message: err?.statusData ?? "", actions: [action])
		}
		hud.dismiss()
	}

	func displayResponseUploadImage(_ data: ResultData<ResponseMedia>) {
        hud.dismiss()
        saveButton.isEnabled = true
		switch data {
			case .failure(let err):
				showAlertUploadError(title: "Upload Gagal", message: err?.statusData ?? "")

			case .success(let data):
				guard let url = data.url else {return showAlertUploadError(title: "Upload Gagal", message: "Terjadi kesalahan, silahkan upload ulang")}
				self.interactor.doRequest(.updateUploadedImageUrl(source: url))
		}
	}

	func showAlertUploadError(title: String, message: String){
		let action = UIAlertAction(title: "Kembali", style: .default)
        let actionRetry = UIAlertAction(title: "Upload Ulang", style: .default, handler: {(alert: UIAlertAction!) in
            guard let item = self.interactor.dataSource.item else { return }
            self.interactor.doRequest(.uploadImage(item: item))
			self.hud.show(in: self.view)
		})
		hud.dismiss()
		self.displayAlert(with: title , message: message, actions: [action,actionRetry])
	}

	func setupNav(){
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrowleft")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.back))
		self.title = "Edit Profile"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14)]

		self.navigationItem.rightBarButtonItem = saveButton

		saveButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 14), NSAttributedString.Key.foregroundColor : UIColor.primary], for: .normal)
	}

	@objc func back(){
		router.routeTo(.dismiss)
	}

	@objc func saveItem(){
		guard let name = mainView.nameCTF.nameTextField.text else { return }
        guard let birthDate = mainView.datePickerTF.nameTextField.text else { return }
        let gender = mainView.gender
        let imageUrl = interactor.dataSource.imageUrl
        
        if name.isEmpty { 
            mainView.nameCTF.showError("Masukkan nama lengkap terlebih dahulu")
            return
        }
        
        let request: EditProfileModel.Request = .updateProfile(bio: mainView.bioCTV.nameTextField.text ?? "", name: name, photo: imageUrl, birthDate: birthDate, gender: gender?.rawValue.uppercased(), socmed: getSocialMedias())
        
        interactor.doRequest(request)
		hud.show(in: view)
	}
    
    func getSocialMedias() -> [SocialMedia] {
        var instagramUrl = mainView.instagramCTF.nameTextField.text ?? ""
        if !instagramUrl.isEmpty && !instagramUrl.isUrl() {
            instagramUrl = "https://www.instagram.com/" + instagramUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var tiktokUrl = mainView.tiktokCTF.nameTextField.text ?? ""
        if !tiktokUrl.isEmpty && !tiktokUrl.isUrl() {
            if tiktokUrl.first != "@" {
                tiktokUrl = "@" + tiktokUrl
            }
            tiktokUrl = "https://www.tiktok.com/" + tiktokUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var wikipediaUrl = mainView.wikipediaCTF.nameTextField.text ?? ""
        if !wikipediaUrl.isEmpty && !wikipediaUrl.isUrl() {
            wikipediaUrl = "https://id.wikipedia.org/wiki/" + wikipediaUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var facebookUrl = mainView.facebookCTF.nameTextField.text ?? ""
        if !facebookUrl.isEmpty && !facebookUrl.isUrl() {
            facebookUrl = "https://www.facebook.com/" + facebookUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var twitterUrl = mainView.twitterCTF.nameTextField.text ?? ""
        if !twitterUrl.isEmpty && !twitterUrl.isUrl() {
            twitterUrl = "https://twitter.com/" + twitterUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let socialMedias: [SocialMedia] = [
            SocialMedia(socialMediaType: SocialMediaType.instagram.rawValue , urlSocialMedia: instagramUrl),
            SocialMedia(socialMediaType: SocialMediaType.tiktok.rawValue , urlSocialMedia: tiktokUrl),
            SocialMedia(socialMediaType: SocialMediaType.wikipedia.rawValue , urlSocialMedia: wikipediaUrl),
            SocialMedia(socialMediaType: SocialMediaType.facebook.rawValue , urlSocialMedia: facebookUrl),
            SocialMedia(socialMediaType: SocialMediaType.twitter.rawValue , urlSocialMedia: twitterUrl),
        ]
        return socialMedias
    }
    
}

extension EditProfileViewController: UIGestureRecognizerDelegate {}
