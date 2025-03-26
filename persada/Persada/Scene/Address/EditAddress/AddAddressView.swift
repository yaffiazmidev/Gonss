//
//  AddAddressView.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class AddAddressView: UIView {
    
    var formController = CustomFormController(alignment: .top)
    var nameHeightAnchor = NSLayoutConstraint()
    var addressHeightAnchor = NSLayoutConstraint()
    var phoneHeightAnchor = NSLayoutConstraint()
    
    var data: Address! {
        didSet {
            addressLabelItemView.nameTextField.text = data?.label ?? ""
            nameItemView.nameTextField.text = data?.receiverName ?? ""
            addressItemView.nameTextField.text = data?.detail ?? ""
            provinceItemView.nameTextField.text = data?.province ?? ""
            cityItemView.nameTextField.text = data?.city ?? ""
            subdistrictItemView.nameTextField.text = data?.subDistrict ?? ""
            codePostItemView.nameTextField.text = data?.postalCode ?? ""
            phoneItemView.nameTextField.text = data?.phoneNumber ?? ""
        }
    }
    
    enum ViewTrait {
        static let leftMargin: CGFloat = 10.0
        static let padding: CGFloat = 16.0
        static let cellId: String = StringEnum.cellID.rawValue
        static let iconSearch: String = String.get(.iconSearch)
        static let widht = UIScreen.main.bounds.width - 24
        static let placeHolderSearch: String = StringEnum.cariAlamatPlaceholder.rawValue
    }
    
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
        
        return customView
    }()
    
    lazy var addressItemView: CustomTextView = {
        let customView = CustomTextView(frame: .zero)
        customView.title = StringEnum.alamat.rawValue
        customView.placeholder = StringEnum.alamatPlaceholder.rawValue
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.nameTextField.layer.masksToBounds = false
        customView.nameTextField.layer.cornerRadius = 8
        customView.nameTextField.layer.borderWidth = 1
        customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        customView.nameTextField.backgroundColor = .white
        customView.nameTextField.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return customView
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
        customView.nameTextField.maxLength = 12
        
        return customView
    }()
    lazy var buttonAddAddress: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle(StringEnum.tambah.rawValue, for: .normal)
        button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 16))
        return button
    }()
    
    lazy var namaAlamatTitleLabel : UILabel = {
            let label = UILabel(text: String.get(.namaAlamat), font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 1)
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

    
    lazy var buttonView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        [buttonAddAddress].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds = false
            $0.layer.cornerRadius = 8
            view.addSubview($0)
        }
        
        buttonAddAddress.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: ViewTrait.padding, paddingRight: ViewTrait.padding, height: 45)

        return view
    }()
    
    lazy var checkBox : UIButton = {
        let button =  UIButton()
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(named: String.get(.iconCheckboxUncheck)), for: .normal)
        return button
    }()

    
    lazy var labelCheckBox : UILabel = {
        let label = UILabel(text: .get(.aturSebagaiAlamatUtama), font: .Roboto(.regular, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    lazy var viewCheckBox : UIView = {
        let view = UIView()
        view.isHidden = true
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
        addSubview(buttonView)
        
        buttonView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding, height: 60)
        
        formView?.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: buttonView.topAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingBottom: ViewTrait.padding, paddingRight: ViewTrait.padding)
        
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
        
        [nameItemView, provinceItemView, cityItemView, subdistrictItemView, codePostItemView, phoneItemView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.nameTextField.layer.masksToBounds = false
            $0.nameTextField.layer.cornerRadius = 8
            $0.nameTextField.layer.borderWidth = 1
            $0.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
            formView?.addSubview($0)
        }
        
        formView?.addSubview(addressItemView)
        
        formController.formContainerStackView.stack(viewNamaAlamat,nameItemView, addressItemView, provinceItemView, cityItemView, subdistrictItemView, codePostItemView, phoneItemView, viewMaps, viewCheckBox, spacing: 16, alignment: .fill, distribution: .fill).withMargins(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))

        checkBox.addTarget(self, action: #selector(setAddCheckboxClick), for: .touchUpInside)
    }
    
    @objc
    func setAddCheckboxClick(){
            if self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxUncheck)) {
             self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxChecked)), for: .normal)
         } else {
             self.checkBox.setImage(UIImage(named: String.get(.iconCheckboxUncheck)), for: .normal)
         }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateToSellerView(){
        nameItemView.title = "Nama Pengirim"
        nameItemView.placeholder = "Masukan nama pengirim"
    }
    
    func disableButton(){
        buttonAddAddress.isEnabled = false
        buttonAddAddress.setup(color: .gainsboro, textColor: .white, font: .Roboto(.bold, size: 16))

    }
    
    func enableButton(){
            buttonAddAddress.isEnabled = true
            buttonAddAddress.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 16))
    }
    
    func getAddress(provinceID : String, cityID: String, subDistrictID : String, type : AddressFetchType, lat: String, lng: String, isFirstAdded: Bool) -> Address {
        
        var address = Address()
        address.isDefault = false
        address.isDelivery = false
        address.latitude = lat
        address.longitude = lng
//        address.cityType = ""
        address.id = ""
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
            if isFirstAdded {
                address.isDefault = true
            } else {
                address.isDefault = self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxChecked)) ? true : false
            }
        } else if type == .seller {
            address.senderName = nameItemView.nameTextField.text
            address.receiverName = ""
            
            address.isDefault = false
            if isFirstAdded {
                address.isDelivery = true
            } else {
                address.isDelivery = self.checkBox.currentImage == UIImage(named: String.get(.iconCheckboxChecked)) ? true : false
            }
        }
        
        return address
    }

    
    func updateMaps(address : String){
        labelPinPointAddress.text = address
        labelPinPointTitle.text = .get(.pinPoint)
        imageMaps.image = UIImage(named: .get(.imageMaps))
    }
}
