//
//  EditAddressView.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class EditAddressView: UIView {
    
    var formController = CustomFormController(alignment: .top)
    var nameHeightAnchor = NSLayoutConstraint()
    var addressHeightAnchor = NSLayoutConstraint()
    var phoneHeightAnchor = NSLayoutConstraint()
    
    enum ViewTrait {
        static let leftMargin: CGFloat = 10.0
        static let padding: CGFloat = 16.0
        static let cellId: String = StringEnum.cellID.rawValue
        static let iconSearch: String = String.get(.iconSearch)
        static let width = UIScreen.main.bounds.width - 24
        static let placeHolderSearch: String = StringEnum.cariAlamatPlaceholder.rawValue
    }
    
    var data: Address! {
        didSet {
            if let name = data.senderName {
                if name.isEmpty {
                    nameItemView.nameTextField.text = data.receiverName ?? ""
                } else {
                    nameItemView.nameTextField.text = data.senderName ?? ""
                }
            }
            
            if data.isDefault ?? false || data.isDelivery ?? false {
                self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxChecked)), for: .normal)
            } else {
                self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxUncheck)), for: .normal)
            }
            
            addressLabelItemView.nameTextField.text = data?.label ?? ""
            addressItemView.nameTextField.text = data.detail ?? ""
            provinceItemView.nameTextField.text = data.province ?? ""
            cityItemView.nameTextField.text = data.city ?? ""
            subdistrictItemView.nameTextField.text = data.subDistrict ?? ""
            codePostItemView.nameTextField.text = data.postalCode ?? ""
            phoneItemView.nameTextField.text = data.phoneNumber ?? ""
            
            switch data?.label {
                        case NamaAlamatEnum.rumah.rawValue:
                            let indexPath = IndexPath(item: 0, section: 0)
                            DispatchQueue.main.async {
                                self.namaAlamatCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                                self.addressLabelItemView.nameTextField.text = "Rumah"
                            }
                        case NamaAlamatEnum.kantor.rawValue:
                            let indexPath = IndexPath(item: 1, section: 0)
                            DispatchQueue.main.async {
                                self.namaAlamatCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                                self.addressLabelItemView.nameTextField.text = "Kantor"
                            }
                        case NamaAlamatEnum.gudang.rawValue:
                            let indexPath = IndexPath(item: 2, section: 0)
                            DispatchQueue.main.async {
                                self.namaAlamatCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                                self.addressLabelItemView.nameTextField.text = "Gudang"
                            }
                        default:
                            break
                        }

        }
    }
    
    lazy var namaAlamatTitleLabel : UILabel = {
            let label = UILabel(text: String.get(.namaAlamat), font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 1)
            return label
        }()
        
        lazy var namaAlamatCollectionView : UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 24, height: 24), collectionViewLayout: layout)
            collection.collectionViewLayout = layout
            collection.backgroundColor = .clear
            collection.backgroundView = UIView.init(frame: CGRect.zero)
            collection.register(AddressNameItemCell.self, forCellWithReuseIdentifier: String.get(.cellID))
            collection.showsHorizontalScrollIndicator = false
            return collection
        }()

    
    lazy var addressLabelItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.placeholder = StringEnum.labelAlamatPlaceholder.rawValue
        customView.title = StringEnum.labelAlamat.rawValue
        
        
        return customView
    }()
    
    lazy var nameItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.placeholder = StringEnum.namaPenerimaPlaceholder.rawValue
        customView.title = StringEnum.namaPenerima.rawValue
        customView.nameTextField.maxLength = 40
        
        return customView
    }()
    
    lazy var addressItemView: CustomTextView = {
        let customView = CustomTextView(frame: .zero)
        customView.title = StringEnum.alamat.rawValue
//        customView.placeholder = StringEnum.alamatPlaceholder.rawValue
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.nameTextField.layer.cornerRadius = 8
        customView.nameTextField.layer.borderWidth = 1
        customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        customView.nameTextField.backgroundColor = .white
        customView.nameTextField.clipsToBounds = true
        customView.nameTextField.tintColor = .primary
        customView.nameTextField.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return customView
    }()
    
    lazy var viewNamaAlamat : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isUserInteractionEnabled = true
            [namaAlamatTitleLabel, namaAlamatCollectionView].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
            
            namaAlamatTitleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
            
            namaAlamatCollectionView.anchor(top: namaAlamatTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
            
            return view
        }()

    
    lazy var provinceItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.title = StringEnum.provinsi.rawValue
        customView.placeholder = StringEnum.provinsiPlaceholder.rawValue
        
        return customView
    }()
    
    lazy var cityItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.title = StringEnum.kotaKabupaten.rawValue
        customView.placeholder = StringEnum.kotaKabupatenPlaceholder.rawValue
        
        return customView
    }()
    
    lazy var subdistrictItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.title = StringEnum.kecamatan.rawValue
        customView.placeholder = StringEnum.kecamatanPlaceholder.rawValue
        
        return customView
    }()
    
    
    lazy var codePostItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.title = StringEnum.kodePos.rawValue
        customView.placeholder = StringEnum.kodePosPlaceholder.rawValue
        customView.nameTextField.keyboardType = UIKeyboardType.numberPad
        return customView
    }()
    
    lazy var phoneItemView: CustomTextField = {
        let customView = CustomTextField(frame: .zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.title = StringEnum.nomorTelepon.rawValue
        customView.placeholder = StringEnum.nomorTeleponPlaceholder.rawValue
        customView.nameTextField.keyboardType = UIKeyboardType.phonePad
        customView.nameTextField.layer.cornerRadius = 8
        customView.nameTextField.layer.borderWidth = 1
        customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        
        customView.nameTextField.maxLength = 12
        return customView
    }()
    
    lazy var buttonSaveAddress: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle(StringEnum.simpan.rawValue, for: .normal)
        button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 14))
        return button
    }()
    
    lazy var buttonRemoveAddress: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle(StringEnum.hapusAlamat.rawValue, for: .normal)
        button.setup(color: .whiteSnow, textColor: .primary, font: .Roboto(.bold, size: 14))
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buttonRemoveAddress, buttonSaveAddress])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()
    
    lazy var checkBox : UIButton = {
        let button =  UIButton()
        button.setImage(UIImage(named: String.get(.iconCheckboxUncheck)), for: .normal)
        return button
    }()

    
    lazy var labelCheckBox : UILabel = {
        let label = UILabel(text: "Atur sebagai alamat utama", font: .Roboto(.regular, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    lazy var viewCheckBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        [checkBox, labelCheckBox].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        checkBox.anchor(left: view.leftAnchor, paddingRight: 10)
        
        labelCheckBox.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: checkBox.rightAnchor, paddingTop: 5, paddingLeft: 10)
        return view
    }()
    
    lazy var imageMaps : UIImageView = {
        let image = UIImageView(image: UIImage(named: .get(.imageMapsEmpty)))
        return image
    }()
    
    lazy var labelPinPointTitle : UILabel = {
        let label = UILabel(text: .get(.pasangPinPoint), font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    lazy var labelPinPointAddress : UILabel = {
        let label = UILabel(text: .get(.pinPointDescription), font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 2)
        return label
    }()
    
    lazy var viewMaps : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.whiteSmoke.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        [imageMaps, labelPinPointTitle, labelPinPointAddress].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        imageMaps.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, width: 60, height: 60)
        
        labelPinPointTitle.anchor(top: view.topAnchor, left: imageMaps.rightAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 8)
        
        labelPinPointAddress.anchor(top: labelPinPointTitle.bottomAnchor, left: imageMaps.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12, paddingRight: 8)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureForm()
    }
    
    private func configureForm() {
        
        let formView = formController.view
        formView?.isUserInteractionEnabled = true
        formController.scrollView.isUserInteractionEnabled = true
        formView?.backgroundColor = .white
        addSubview(formView!)
        addSubview(buttonStackView)
        
        buttonStackView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
        
        formView?.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: buttonStackView.topAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingBottom: ViewTrait.padding, paddingRight: ViewTrait.padding)
        
        [provinceItemView, cityItemView, subdistrictItemView, codePostItemView].forEach {
            $0.constrainHeight(80)
        }
        
        nameHeightAnchor = nameItemView.heightAnchor.constraint(equalToConstant: 80)
        nameHeightAnchor.isActive = true
        addressHeightAnchor = addressItemView.heightAnchor.constraint(equalToConstant: 140)
        addressHeightAnchor.isActive = true
        phoneHeightAnchor = phoneItemView.heightAnchor.constraint(equalToConstant: 80)
        phoneHeightAnchor.isActive = true
        
        viewNamaAlamat.constrainHeight(90)
        viewCheckBox.constrainHeight(40)
        viewMaps.constrainHeight(76)
        
        [nameItemView, provinceItemView, cityItemView, subdistrictItemView, codePostItemView].forEach {
            $0.nameTextField.layer.cornerRadius = 8
            $0.nameTextField.layer.borderWidth = 1
            $0.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
            formView?.addSubview($0)
        }
        
        formView?.addSubview(phoneItemView)
        formView?.addSubview(addressItemView)
        
        formController.formContainerStackView.stack(viewNamaAlamat, nameItemView, addressItemView, provinceItemView, cityItemView, subdistrictItemView, codePostItemView, phoneItemView, viewMaps, viewCheckBox, spacing: 16, alignment: .fill, distribution: .fill).withMargins(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        
        
        checkBox.addTarget(self, action: #selector(setCheckboxClick), for: .touchUpInside)
    }
    
    @objc
    func setCheckboxClick(){
        if self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxUncheck)) {
         self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxChecked)), for: .normal)
     } else {
         self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxUncheck)), for: .normal)
     }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func disableButton(){
        buttonSaveAddress.isEnabled = false
        buttonSaveAddress.setup(color: .gainsboro, textColor: .white, font: .Roboto(.bold, size: 16))

    }
    
    func enableButton(){
        buttonSaveAddress.isEnabled = true
        buttonSaveAddress.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 16))
    }
    
    func updateToSellerView(){
        nameItemView.title = "Nama Pengirim"
        nameItemView.placeholder = "Masukan nama pengirim"
    }
    
    func updateIsMultipleAddress(_ isMultipleAddress: Bool) {
        viewCheckBox.isUserInteractionEnabled = isMultipleAddress
        viewCheckBox.alpha = isMultipleAddress ? 1 : 0.5
        viewCheckBox.isHidden = !isMultipleAddress
        buttonRemoveAddress.isUserInteractionEnabled = isMultipleAddress
        buttonRemoveAddress.alpha = isMultipleAddress ? 1 : 0.5
        buttonRemoveAddress.isHidden = !isMultipleAddress
    }

    func getAddress(provinceID : String, cityID: String, subDistrictID : String, type : AddressFetchType, lat: String, lng: String) -> Address {
        
        var address = Address()
        address.latitude = lat
        address.longitude = lng
//        address.cityType = ""
//        address.id = ""
        address.accountId = ""
        address.addressType = type.rawValue
        address.provinceId = provinceID
        address.cityId = cityID
        address.subDistrictId = subDistrictID
        address.label = addressLabelItemView.nameTextField.text
        address.detail = addressItemView.nameTextField.text
        address.province = provinceItemView.nameTextField.text
        address.city = cityItemView.nameTextField.text
        address.subDistrict = subdistrictItemView.nameTextField.text
        address.postalCode = codePostItemView.nameTextField.text
        address.phoneNumber = phoneItemView.nameTextField.text
        
        if type == .buyer {
            address.receiverName = nameItemView.nameTextField.text
            address.senderName = ""
            
            address.isDelivery = false
            address.isDefault = self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxChecked)) ? true : false
        } else if type == .seller {
            address.senderName = nameItemView.nameTextField.text
            address.receiverName = ""
            
            address.isDefault = false
            address.isDelivery = true
//            self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxChecked)) ? true : false
        }
        
        return address
    }
    
    func updateMaps(address : String){
        labelPinPointAddress.text = address
        labelPinPointTitle.text = .get(.pinPoint)
        imageMaps.image = UIImage(named: .get(.imageMaps))
    }
}

extension EditAddressView: DRHTextFieldWithCharacterCountDelegate {
    func imageTapped() {}
    func rightViewItem() -> UIView { return UIView() }
}
