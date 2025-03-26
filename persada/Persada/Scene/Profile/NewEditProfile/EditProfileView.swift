//
//  EditProfileView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import Combine
import KipasKipasShared

protocol EditProfileViewDelegate where Self: UIViewController {
	
	func whenUploadButtonClicked()
}

protocol EditProfileViewDataSource where Self: UIViewController {
	
}

final class EditProfileView: UIView {
	
	weak var delegate: EditProfileViewDelegate?
	weak var dataSource: EditProfileViewDataSource?
	
    var gender: GenderType? = nil {
        didSet {
            guard let validGender = gender else { return }
            updateGenderView(gender: validGender)
        }
    }
    
	var formController = CustomFormController(alignment: .top)
	
    private var cancellables: Set<AnyCancellable> = []
    
	private enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
	}
	
	lazy var profilePhotoImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.layer.cornerRadius = 16
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
        imageView.accessibilityIdentifier = "imageView-editprofile"
		return imageView
	}()
	
	lazy var uploadPhotoButton: UIButton = {
		let button: UIButton = UIButton()
		button.layer.cornerRadius = 8
		button.backgroundColor = .secondaryLowTint
		button.setTitle( .get(.photoUpload), for: .normal)
		button.titleLabel?.font = .Roboto(.medium, size: 14)
		button.addTarget(self, action: #selector(self.uploadPhotoClicked), for: .touchUpInside)
		button.setTitleColor(.secondary, for: .normal)
        button.accessibilityIdentifier = "upload-button-editprofile"
		return button
	}()
	
	 lazy var nameCTF: CustomTextField = {
		let customTextField: CustomTextField = CustomTextField()
		customTextField.nameLabel.text = .get(.fullNameText)
		customTextField.nameLabel.textColor = .grey
		customTextField.nameLabel.font = .Roboto(.medium, size: 14)
		customTextField.nameTextField.layer.cornerRadius = 8
		customTextField.nameTextField.placeholder = .get(.namePlaceholder)
		customTextField.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		customTextField.nameTextField.layer.borderWidth = 1
		customTextField.nameTextField.backgroundColor = .white
        customTextField.accessibilityIdentifier = "name-tf-editprofile"
         customTextField.handleTextFieldEditingChanged = handleNameChanged
		return customTextField
	}()
    
    lazy var bioCTV: CustomTextView = {
        let customView = CustomTextView(frame: .zero)
        customView.title = "Bio"
        customView.nameLabel.font = .Roboto(.medium, size: 14)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.nameTextField.layer.cornerRadius = 8
        customView.nameTextField.layer.borderWidth = 1
        customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        customView.nameTextField.backgroundColor = .white
        customView.nameTextField.clipsToBounds = true
        customView.nameTextField.tintColor = .primary
        customView.nameTextField.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        customView.maxLength = 100
        customView.accessibilityIdentifier = "bio-tf-editprofile"
        return customView
    }()
    
    let datePicker = UIDatePicker()
    
    lazy var datePickerTF: CustomTextField = {
        let customTextField: CustomTextField = CustomTextField()
        customTextField.title = .get(.birthDate)
        customTextField.nameLabel.font = .Roboto(.medium, size: 14)
        customTextField.nameTextField.setCornerRadius = 8
        customTextField.nameTextField.setBorderWidth = 1
        customTextField.nameTextField.setBorderColor = .whiteSmoke
        customTextField.nameTextField.placeholder = .get(.birthDatePlaceHolder)
        customTextField.nameTextField.backgroundColor = .white
        customTextField.nameLabel.textColor = .grey
        customTextField.translatesAutoresizingMaskIntoConstraints = false
        customTextField.accessibilityIdentifier = "datepicker-tf-editprofile"
        return customTextField
    }()
    
    lazy var gendersView: GendersView = {
        let view = GendersView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel.font = .Roboto(.medium, size: 14)
        view.accessibilityIdentifier = "genders-editprofile"
        return view
    }()
	
	lazy var instagramCTF: CustomTextFieldWithIcon = {
		let ctv: CustomTextFieldWithIcon = CustomTextFieldWithIcon(backgroundColor: .white)
		ctv.iconImage.image = UIImage(named: .get(.iconActiveInstagram))
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.placeholder = .get(.inputLinkHere)
		ctv.nameTextField.autocapitalizationType = .none
        ctv.accessibilityIdentifier = "instagram-socmed-editprofile"
		
		return ctv
	}()
	
	let otherSocmedLabel = UILabel(text: .get(.otherSocmed), font: .Roboto(.medium, size: 14), textColor: .grey, textAlignment: .left, numberOfLines: 0)
	
	lazy var tiktokCTF: CustomTextFieldWithIcon = {
		let ctv: CustomTextFieldWithIcon = CustomTextFieldWithIcon(backgroundColor: .white)
		ctv.iconImage.image = UIImage(named: .get(.iconActiveTiktok))
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.placeholder = .get(.inputLinkHere)
		ctv.nameTextField.autocapitalizationType = .none
        ctv.accessibilityIdentifier = "tiktok-socmed-editprofile"
		
		return ctv
	}()
	
	lazy var wikipediaCTF: CustomTextFieldWithIcon = {
		let ctv: CustomTextFieldWithIcon = CustomTextFieldWithIcon(backgroundColor: .white)
		ctv.iconImage.image = UIImage(named: .get(.iconActiveWikipedia))
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.placeholder = .get(.inputLinkHere)
		ctv.nameTextField.autocapitalizationType = .none
        ctv.accessibilityIdentifier = "wikipedia-socmed-editprofile"
		
		return ctv
	}()
	
	lazy var facebookCTF: CustomTextFieldWithIcon = {
		let ctv: CustomTextFieldWithIcon = CustomTextFieldWithIcon(backgroundColor: .white)
		ctv.iconImage.image = UIImage(named: .get(.iconActiveFacebook))
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.placeholder = .get(.inputLinkHere)
		ctv.nameTextField.autocapitalizationType = .none
        ctv.accessibilityIdentifier = "facebook-socmed-editprofile"
		return ctv
	}()
	
	lazy var twitterCTF: CustomTextFieldWithIcon = {
		let ctv: CustomTextFieldWithIcon = CustomTextFieldWithIcon(backgroundColor: .white)
		ctv.placeholder = .get(.inputLinkHere)
		ctv.iconImage.image = UIImage(named: .get(.iconActiveTwitter))
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.nameTextField.autocapitalizationType = .none
        ctv.accessibilityIdentifier = "twitter-socmed-editprofile"
		
		return ctv
	}()
	
	lazy var profileView: UIView = {
		let view = UIView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(profilePhotoImageView)
		view.addSubview(uploadPhotoButton)
		
		profilePhotoImageView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 0, paddingLeft: 0, width: 93, height: 93)
        uploadPhotoButton.anchor(left: profilePhotoImageView.rightAnchor, bottom: profilePhotoImageView.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, height: 48)
        view.accessibilityIdentifier = "profileview-editprofile"
		return view
	}()

    override init(frame: CGRect) {
		super.init(frame: frame)
		
        setupDatePicker()
        handleClickGender()
        setupFormView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func updateProfile(_ profile: EditProfileData?){

		nameCTF.nameTextField.text = profile?.name
		bioCTV.nameTextField.text = profile?.bio
		var photo = "\(profile?.photo ?? "")"
        
        if let birthDate = profile?.birthDate?.toDate(withFormat: "yyyy-MM-dd") {
            datePicker.date = birthDate
        }
        
        datePickerTF.nameTextField.text = profile?.birthDate ?? ""
        
        var genderProfile = profile?.gender ?? ""
        if genderProfile.lowercased() == "male" {
            gender = .male
        } else if genderProfile.lowercased() == "female" {
            gender = .female
        } else if genderProfile.lowercased() == "unknown" {
            gender = .unknown
        }
        
		profilePhotoImageView.loadImage(at: photo)
		profile?.socialMedias?.forEach { value in
			if value.socialMediaType?.contains(SocialMediaType.instagram.rawValue) == true {
				instagramCTF.nameTextField.text = value.urlSocialMedia ?? ""
			} else if (value.socialMediaType?.contains(SocialMediaType.tiktok.rawValue) == true) {
				tiktokCTF.nameTextField.text = value.urlSocialMedia ?? ""
			} else if (value.socialMediaType?.contains(SocialMediaType.wikipedia.rawValue) == true) {
				wikipediaCTF.nameTextField.text = value.urlSocialMedia ?? ""
			} else if (value.socialMediaType?.contains(SocialMediaType.facebook.rawValue) == true) {
				facebookCTF.nameTextField.text = value.urlSocialMedia ?? ""
			} else if (value.socialMediaType?.contains(SocialMediaType.twitter.rawValue) == true) {
				twitterCTF.nameTextField.text = value.urlSocialMedia ?? ""
			}
		}
	}

	@objc func uploadPhotoClicked() {
		delegate?.whenUploadButtonClicked()
	}
    
    @objc
    func dateChange(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        datePickerTF.nameTextField.text = formatter.string(from: datePicker.date)
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 200)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        datePickerTF.nameTextField.inputView = datePicker
    }
    
    lazy var space1: UIView = UIView(backgroundColor: .gainsboro)
    lazy var space2: UIView = UIView(backgroundColor: .gainsboro)
    
    fileprivate func setupFormView() {
        let formView = formController.view!
        formView.isUserInteractionEnabled = true
        formController.scrollView.isUserInteractionEnabled = true
        formView.backgroundColor = .white
        addSubview(formView)
        
        formView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
        
        otherSocmedLabel.constrainHeight(30)
        profileView.constrainHeight(100)
        nameCTF.constrainHeight(90)
        bioCTV.constrainHeight(160)
        space1.constrainHeight(1)
        datePickerTF.constrainHeight(80)
        gendersView.constrainHeight(300)
        space2.constrainHeight(1)
        instagramCTF.constrainHeight(50)
        tiktokCTF.constrainHeight(50)
        wikipediaCTF.constrainHeight(50)
        facebookCTF.constrainHeight(50)
        twitterCTF.constrainHeight(50)
        
        let socmedStack = UIStackView(arrangedSubviews: [otherSocmedLabel, instagramCTF, tiktokCTF, wikipediaCTF, facebookCTF, twitterCTF])
        socmedStack.spacing = 10
        socmedStack.alignment = .fill
        socmedStack.distribution = .fill
        socmedStack.axis = .vertical
        
        formController.formContainerStackView.stack(
            profileView ,nameCTF, bioCTV, space1, datePickerTF, gendersView, space2, socmedStack,
            spacing: 16, alignment: .fill, distribution: .fillProportionally)
        
        nameCTF.nameTextField.delegate = self
        
        let nameValidator = NonEmptyValidator(errorMessage: "Masukkan nama lengkap terlebih dahulu")
        nameCTF.nameTextField.validationPublisher(with: nameValidator)
            .sink { [weak self] validatedName in
                guard let self = self else { return }
                
                nameCTF.showError(validatedName.error?.message)
            }
            .store(in: &cancellables)
    }
    
    func handleClickGender() {
        gendersView.handleClick = { [weak self] gender in
            guard let self = self else { return }
            if gender == .male {
                self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuyFill))!, iconGirl: UIImage(named: .get(.iconPersonGirl))!, iconUnknown: UIImage(named: .get(.iconPersonUnknown))!)
                self.setBorderLineColor(guyColor: .secondary, girlColor: .clear, unknownColor: .clear)
                self.setBorderLineWidth(guyWidthLine: 1, girlWidthLine: 0, unknownWidthLine: 0)
            } else if gender == .female {
                self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuy))!, iconGirl: UIImage(named: .get(.iconPersonGirlFill))!, iconUnknown: UIImage(named: .get(.iconPersonUnknown))!)
                self.setBorderLineColor(guyColor: .clear, girlColor: .primary, unknownColor: .clear)
                self.setBorderLineWidth(guyWidthLine: 0, girlWidthLine: 1, unknownWidthLine: 0)
            } else {
                self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuy))!, iconGirl: UIImage(named: .get(.iconPersonGirl))!, iconUnknown: UIImage(named: .get(.iconPersonUnknownFill))!)
                self.setBorderLineColor(guyColor: .clear, girlColor: .clear, unknownColor: .greenLawn)
                self.setBorderLineWidth(guyWidthLine: 0, girlWidthLine: 0, unknownWidthLine: 1)
            }
            self.gender = gender
        }
    }
    
}

extension EditProfileView: DRHTextFieldWithCharacterCountDelegate {
	func imageTapped() {
		
	}
	
	func rightViewItem() -> UIView {
		return UIView()
	}
	
    func setIconGenderWith(iconGuy: UIImage, iconGirl: UIImage, iconUnknown: UIImage) {
        gendersView.personGirlView.personImageView.image = iconGirl
        gendersView.personGuyView.personImageView.image = iconGuy
        gendersView.personUnknownView.unknownPersonImageView.image = iconUnknown
    }
    
    func setBorderLineColor(guyColor: UIColor, girlColor: UIColor, unknownColor: UIColor) {
        gendersView.personGuyView.personView.layer.borderColor = guyColor.cgColor
        gendersView.personGirlView.personView.layer.borderColor = girlColor.cgColor
        gendersView.personUnknownView.unknownPersonView.layer.borderColor = unknownColor.cgColor
    }
    
    func setBorderLineWidth(guyWidthLine: Int, girlWidthLine: Int, unknownWidthLine: Int) {
        gendersView.personGirlView.personView.layer.borderWidth = CGFloat(girlWidthLine)
        gendersView.personGuyView.personView.layer.borderWidth = CGFloat(guyWidthLine)
        gendersView.personUnknownView.unknownPersonView.layer.borderWidth = CGFloat(unknownWidthLine)
    }
    
    func setTextGender(guyTextColor: UIColor, girlTextColor: UIColor, unknownTextColor: UIColor) {
        gendersView.personGirlView.personLabel.textColor = guyTextColor
        gendersView.personGuyView.personLabel.textColor = guyTextColor
        gendersView.personUnknownView.unknownPersonLabel.textColor = unknownTextColor
    }
    
    func updateGenderView(gender: GenderType) {
        if gender == .male {
            self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuyFill))!, iconGirl: UIImage(named: .get(.iconPersonGirl))!, iconUnknown: UIImage(named: .get(.iconPersonUnknown))!)
            self.setBorderLineColor(guyColor: .secondary, girlColor: .clear, unknownColor: .clear)
            self.setBorderLineWidth(guyWidthLine: 1, girlWidthLine: 0, unknownWidthLine: 0)
        } else if gender == .female {
            self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuy))!, iconGirl: UIImage(named: .get(.iconPersonGirlFill))!, iconUnknown: UIImage(named: .get(.iconPersonUnknown))!)
            self.setBorderLineColor(guyColor: .clear, girlColor: .primary, unknownColor: .clear)
            self.setBorderLineWidth(guyWidthLine: 0, girlWidthLine: 1, unknownWidthLine: 0)
        } else if gender == .unknown {
            self.setIconGenderWith(iconGuy: UIImage(named: .get(.iconPersonGuy))!, iconGirl: UIImage(named: .get(.iconPersonGirl))!, iconUnknown: UIImage(named: .get(.iconPersonUnknownFill))!)
            self.setBorderLineColor(guyColor: .clear, girlColor: .clear, unknownColor: .greenLawn)
            self.setBorderLineWidth(guyWidthLine: 0, girlWidthLine: 0, unknownWidthLine: 1)
        }
    }
}

extension EditProfileView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 100
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}


extension EditProfileView {
    private func handleNameChanged(field: UITextField){
        if field.text == " " {
            field.text = ""
        }
    }
}
