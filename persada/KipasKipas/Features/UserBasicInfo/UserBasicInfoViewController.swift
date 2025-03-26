import UIKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import FeedCleeps
import KipasKipasLogin
import KipasKipasShared

class UserBasicInfoViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var dobView: KKTextField!
    @IBOutlet weak var emailView: KKTextField!
    @IBOutlet weak var fullnameView: KKTextField!
    @IBOutlet weak var usernameView: KKTextField!
    @IBOutlet weak var passwordView: KKTextField!
    @IBOutlet weak var genderGuyView: UIView!
    @IBOutlet weak var genderGirlView: UIView!
    @IBOutlet weak var genderUnknowView: UIView!
    @IBOutlet weak var genderGuyIcon: UIImageView!
    @IBOutlet weak var genderGirlIcon: UIImageView!
    @IBOutlet weak var genderUnknowIcon: UIImageView!
    @IBOutlet weak var genderGuyTitleLabel: UILabel!
    @IBOutlet weak var genderGirlTitleLabel: UILabel!
    @IBOutlet weak var genderUnknowTitleLabel: UILabel!
    @IBOutlet weak var checkBoxIcon: UIImageView!
    @IBOutlet weak var termsAndConLabel: UILabel!
    @IBOutlet weak var agreedTermsStackView: UIStackView!
    @IBOutlet weak var letsGoButton: UIButton!
    
    private let datePicker = UIDatePicker()
    private var validateAllData = ValidateAllData()
    private let delegate: InputUserDelegate
    private let inputUser: InputUserParams
    private var user: CreateNewUser? = CreateNewUser()
    private let loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .primary, padding: 0)
    
    private enum Gender: String {
        case guy = "MALE"
        case girl = "FEMALE"
        case unknow = "UNKNOWN"
    }
    
    private let onSuccessCreateNewUser: ((_ userId: String) -> Void)
    
    init(
        delegate: InputUserDelegate,
        inputUser: InputUserParams,
        onSuccessCreateNewUser: @escaping (_ userId: String) -> Void
    ) {
        self.delegate = delegate
        self.inputUser = inputUser
        self.onSuccessCreateNewUser = onSuccessCreateNewUser
        super.init(nibName: nil, bundle: nil)
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        setupTermsAndConLabelAttribute()
        handleFieldDelegate()
        setupDatePicker()
        handleOnTap()
        disableLetsGoButton()
        
        fullnameView.textField.maxLength = 100
        usernameView.textField.maxLength = 20
        passwordView.textField.maxLength = 20
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
    }
    
    private func setupLoadingView() {
        view.addSubview(loading)
        loading.centerInSuperview(size: CGSize(width: 40, height: 40))
    }
    
    private func startLoading() {
        loading.startAnimating()
    }

    private func stopLoading() {
        loading.stopAnimating()
    }
    
    private func setupDatePicker() {
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.frame.size = CGSize(width: 0, height: 200)
        dobView.textField.inputView = datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
    }
    
    @objc private func dateChange(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        dobView.textField.text = formatter.string(from: datePicker.date)
        formatter.dateFormat = "yyyy-MM-dd"
        
        user?.birthDate = formatter.string(from: datePicker.date)
//        validateAllData.dateOfBirth = true
        checkIsEnableLetsGoButton()
    }
    
    private func setupTermsAndConLabelAttribute() {
        // Underline style
        let textRange = NSRange(location: 0, length: termsAndConLabel.text?.count ?? 0)
        let attributedText = NSMutableAttributedString(string: termsAndConLabel.text ?? "")
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
        termsAndConLabel.attributedText = attributedText
    }
    
    private func setupDefaultGenderView() {
        genderGuyIcon.tintColor = .gray
        genderGirlIcon.tintColor = .gray
        genderUnknowIcon.tintColor = .gray
        genderGuyView.setBorderColor = .clear
        genderGirlView.setBorderColor = .clear
        genderUnknowView.setBorderColor = .clear
        genderGuyTitleLabel.textColor = UIColor.grey
        genderGirlTitleLabel.textColor = UIColor.grey
        genderUnknowTitleLabel.textColor = UIColor.grey
        genderGuyIcon.image = genderGuyIcon.image?.withRenderingMode(.alwaysTemplate)
        genderGirlIcon.image = genderGirlIcon.image?.withRenderingMode(.alwaysTemplate)
        genderUnknowIcon.image = genderUnknowIcon.image?.withRenderingMode(.alwaysTemplate)
    }
    
    private func selectedGender(to gender: Gender) {
//        validateAllData.gender = true
        user?.gender = gender.rawValue
        setupDefaultGenderView()
        checkIsEnableLetsGoButton()
        
        switch gender {
        case .guy:
            genderGuyView.setBorderColor = .secondary
            genderGuyIcon.tintColor = .secondary
            genderGuyTitleLabel.textColor = .secondary
        case .girl:
            genderGirlView.setBorderColor = .primary
            genderGirlIcon.tintColor = .primary
            genderGirlTitleLabel.textColor = .primary
        case .unknow:
            genderUnknowView.setBorderColor = .success
            genderUnknowIcon.tintColor = .success
            genderUnknowTitleLabel.textColor = .success
        }
    }
    
    private func handleOnTap() {
        genderGuyView.onTap { [weak self] in
            guard let self = self else { return }
            self.selectedGender(to: .guy)
            self.user?.gender = GenderType.male.rawValue
        }
        
        genderGirlView.onTap { [weak self] in
            guard let self = self else { return }
            self.selectedGender(to: .girl)
            self.user?.gender = Gender.girl.rawValue
        }
        
        genderUnknowView.onTap { [weak self] in
            guard let self = self else { return }
            self.selectedGender(to: .unknow)
            self.user?.gender = Gender.unknow.rawValue
        }
        
        agreedTermsStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleCheckUncheckBox()
        }
        
        passwordView.handleTapRightIcon = { [weak self] in
            guard let self = self else { return }
            self.handleShowHidePassword()
        }
        
        termsAndConLabel.onTap { [weak self] in
            guard let self = self else { return }
            
            let browserController = AlternativeBrowserController(url: .get(.kipasKipasTermsConditionsUrl))
            browserController.bindNavigationBar(.get(.syaratKetentuan), false)
            
            let navigate = UINavigationController(rootViewController: browserController)
            navigate.modalPresentationStyle = .fullScreen

            self.present(navigate, animated: true, completion: nil)
        }
    }
    
    private func handleCheckUncheckBox() {
        let isChecked = checkBoxIcon.tag != 0
        checkBoxIcon.tag = isChecked ? 0 : 1
        checkBoxIcon.image = UIImage(
            named: .get(isChecked ? .iconCheckboxUncheck : .iconCheckboxCheckedBlue)
        )
        validateAllData.agreeTnC = !isChecked
        checkIsEnableLetsGoButton()
    }
    
    private func handleShowHidePassword() {
        passwordView.secureTextEntry = !passwordView.secureTextEntry
        passwordView.rightIcon = UIImage.init(systemName: passwordView.secureTextEntry ? "eye.slash" : "eye")
    }
    
    private func handleFieldDelegate() {
        fullnameView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            self.fullnameValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        fullnameView.handleTextFieldShouldEndEditing = { [weak self] textField in
            guard let self = self else { return }
            self.fullnameValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        usernameView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            self.usernameValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        usernameView.handleTextFieldShouldEndEditing = { [weak self] textField in
            guard let self = self else { return }
            self.usernameValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        emailView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            self.emailValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        emailView.handleTextFieldShouldEndEditing = { [weak self] textField in
            guard let self = self else { return }
            self.emailValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        passwordView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            self.passwordValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
        
        passwordView.handleTextFieldShouldEndEditing = { [weak self] textField in
            guard let self = self else { return }
            self.passwordValidation(textField)
            self.checkIsEnableLetsGoButton()
        }
    }
    
    private func enableLetsGoButton() {
        letsGoButton.isEnabled = true
        letsGoButton.backgroundColor = .primary
    }
    
    private func disableLetsGoButton() {
        letsGoButton.isEnabled = false
        letsGoButton.backgroundColor = .gainsboro
    }
    
    private func checkIsEnableLetsGoButton() {
        validateAllData.isAllValidated() ? enableLetsGoButton() : disableLetsGoButton()
    }
    
    private func fullnameValidation(_ textField: UITextField) {
        validateAllData.fullname = false
        guard let text = textField.text, !text.isEmpty else {
            fullnameView.showError(.get(.fullnameNotEmpty))
            return
        }
        
        fullnameView.hideError()
        validateAllData.fullname = true
        user?.name = text
    }
    
    private func usernameValidation(_ textField: UITextField) {
        validateAllData.username = false
        guard let text = textField.text, !text.isEmpty else {
            usernameView.showError(.get(.usernameNotEmpty))
            return
        }
        
        if text.isValidUsername() {
            usernameView.hideError()
            validateAllData.username = true
            user?.username = text
            delegate.didValidateUsername(request: UsernameValidatorRequest(username: text.trim().lowercased()))
        } else {
            if text.count < 21 {
                usernameView.showError(.get(.errorUsernameNotAllowSpecialCharacterAtFirstOrLast))
            }
        }
    }
    
    private func emailValidation(_ textField: UITextField) {
        validateAllData.email = false
        guard let text = textField.text, !text.isEmpty else {
            emailView.showError(.get(.emailShouldNotEmpty))
            return
        }
        
        if !text.isValidEmail() {
            emailView.showError(.get(.emailNotValid))
        } else {
            emailView.hideError()
            validateAllData.email = true
            user?.email = text
            delegate.didValidateEmail(request: EmailValidatorRequest(email: text.trim()))
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        validateAllData.password = false
        guard let text = textField.text, !text.isEmpty else {
            passwordView.showError(.get(.passwordNotEmpty))
            return
        }
        
        if !text.isValidPassword {
            passwordView.showError(.get(.passwordValid))
        } else {
            passwordView.hideError()
            validateAllData.password = true
            user?.password = text
        }
    }
    
    private func dobValidation(_ textField: UITextField) {
//        validateAllData.dateOfBirth = false
        guard let text = textField.text, !text.isEmpty else {
            dobView.showError(.get(.fieldNotEmpty))
            return
        }
        
        dobView.hideError()
//        validateAllData.dateOfBirth = true
    }
    
    @IBAction func didClickUploadPhotoButton(_ sender: Any) {
        let imagePicketController = UIImagePickerController()
        imagePicketController.delegate = self
        imagePicketController.allowsEditing = true
        
        self.present(imagePicketController, animated: true, completion: nil)
    }
    
    @IBAction func didClickLetsGoButton(_ sender: Any) {
        guard validateAllData.isAllValidated() else {
            fullnameValidation(fullnameView.textField)
            usernameValidation(usernameView.textField)
            emailValidation(emailView.textField)
            passwordValidation(passwordView.textField)
//            dobValidation(dobView.textField)
            return
        }
        
        let refCode = DataCache.instance.readString(forKey: "REFFCODE")
        let request = CreateUserRequest(
            name: user?.name.trim() ?? "",
            mobile: inputUser.phone,
            password: user?.password ?? "",
            photo: user?.photo ?? "",
            username: user?.username.trim().lowercased() ?? "",
            otpCode: inputUser.otp,
            birthDate: user?.birthDate ?? "",
            gender: user?.gender ?? "",
            deviceId: user?.deviceId ?? "",
            email: user?.email.trim() ?? "",
            referralCode: refCode ?? ""
        )
        delegate.didCreateUser(request: request)
    }
}

extension UserBasicInfoViewController: EmailValidatorView, EmailValidatorLoadingView, EmailValidatorLoadingErrorView, EmailValidatorAlreadyExistsView {
    
    func display(_ viewModel: EmailValidatorViewModel) {
        if viewModel.item.data == false {
            emailView.hideError()
            validateAllData.email = true
        }
    }
    
    func display(_ viewModel: EmailValidatorLoadingViewModel) { }
    
    func display(_ viewModel: EmailValidatorLoadingErrorViewModel) {
        if let message = viewModel.message {
            invalidateEmailData(with: message)
        }
    }
    
    func display(_ viewModel: EmailValidatorAlreadyExistsViewModel) {
        if let message = viewModel.message {
            invalidateEmailData(with: message)
        }
    }
    
    private func invalidateEmailData(with message: String) {
        emailView.showError(message)
        validateAllData.email = false
    }
}

extension UserBasicInfoViewController: UsernameValidatorView, UsernameValidatorLoadingView, UsernameValidatorLoadingErrorView, UsernameValidatorAlreadyExistsView {
    
    func display(_ viewModel: UsernameValidatorViewModel) {
        if viewModel.item.data == false {
            usernameView.hideError()
            validateAllData.username = true
        }
    }
    
    func display(_ viewModel: UsernameValidatorLoadingViewModel) { }
    
    func display(_ viewModel: UsernameValidatorLoadingErrorViewModel) {
        if let message = viewModel.message {
            invalidateUsernameData(with: message)
        }
    }
    
    func display(_ viewModel: UsernameValidatorAlreadyExistsViewModel) {
        if let message = viewModel.message {
            invalidateUsernameData(with: message)
        }
    }
    
    private func invalidateUsernameData(with message: String) {
        usernameView.showError(message)
        validateAllData.username = false
    }
}

extension UserBasicInfoViewController: UserPhotoUploadView, UserPhotoUploadLoadingView, UserPhotoUploadLoadingErrorView {
    
    func display(_ viewModel: UserPhotoUploadViewModel) {
        user?.photo = viewModel.item.url
        Toast.share.show(message: "Berhasil mengupload foto profile")
    }
    
    func display(_ viewModel: UserPhotoUploadLoadingViewModel) {
        if viewModel.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
    }
    
    func display(_ viewModel: UserPhotoUploadLoadingErrorViewModel) {
        if let message = viewModel.message {
            Toast.share.show(message: message)
        }
    }
}

extension UserBasicInfoViewController: CreateUserView, CreateUserLoadingView, CreateUserLoadingErrorView {
    
    func display(_ viewModel: CreateUserViewModel) {
        let data = viewModel.item
        
        let credentials = LoginResponse(accessToken: data.accessToken, tokenType: "bearer", loginResponseRefreshToken: data.refreshToken, expiresIn: data.expiresIn, scope: nil, userNo: nil, userName: data.userName, userEmail: data.userEmail, userMobile: data.userMobile, accountID: data.accountId, authorities: [], appSource: nil, code: nil, timelapse: nil, role: data.role, jti: nil, token: data.accessToken, refreshToken: data.refreshToken)
        
        DataCache.instance.write(string: "", forKey: "REFFCODE")
        updateLoginData(data: credentials)
//        self.connectSendBird(with: viewModel.item.accountId)
        KKCache.common.remove(key: .trendingCache)
        
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: .clearFeedCleepsData, object: nil, userInfo: [:])
            NotificationCenter.default.post(name: .showOnboardingView, object: nil, userInfo: [:])
        })
        
        onSuccessCreateNewUser(data.accountId)
    }
    
    func display(_ viewModel: CreateUserLoadingViewModel) {
        if viewModel.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
    }
    
    func display(_ viewModel: CreateUserLoadingErrorViewModel) {
        if let message = viewModel.message {
            Toast.share.show(message: message)
        }
    }
}

extension UserBasicInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            image = originalImage
        } else {
            return dismiss(animated: true, completion: nil)
        }
        
        profileImageView.image = image.withRenderingMode(.alwaysOriginal)
        let imageToUpload: UIImage = image
        let imagePath = getDocumentsDirectory().appendingPathComponent("imagename.jpeg")
        let jpegData = imageToUpload.jpegData(compressionQuality: 0.5)
        let imgURL = URL(fileURLWithPath: imagePath)
        try? jpegData!.write(to: imgURL)
        let request = UserPhotoUploadRequest(imageData: jpegData!, ratio: "1:1")
        delegate.didUserPhotoUpload(request: request)
        dismiss(animated: true, completion: nil)
    }
    
}

extension UserBasicInfoViewController {
    /*
    private func getUserBy(id: String) {
        
        struct Root: Codable {
            let code, message: String?
            let data: RootData?
        }
        
        struct RootData: Codable {
            let id: String?
            let username: String?
            let photo: String?
            let isVerified: Bool?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "profile/\(id)",
            method: .get,
            headerParamaters: [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.message)
            case .success(let response):
                UserConnectionUseCase.shared.updateUserInfo(
                    nickname: response?.data?.username ?? "",
                    profileImageURL: response?.data?.photo ?? "")
                { result in
                    print("Update sendbird user profile")
                    switch result {
                    case .success(_):
                        let metaData = ["is_verified": response?.data?.isVerified == true ? "true" : "false"]
                        UserConnectionUseCase.shared.currentUser?.updateMetaData(metaData, completionHandler: { metaData, error in
                            print("Update user metadata")
                        })
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    private func connectSendBird(with id: String) {
        UserConnectionUseCase.shared.login(userId: getIdUser()) { result in
            switch result {
            case .success(_):
                self.getUserBy(id: id)
                UserManager.shared.accountId = getIdUser()
                UserManager.shared.accessToken = getToken()
                print("SendbirdChat: Success to cennect")
            case .failure(let error):
                print("SendbirdChat: Error: Failed to cennect \(error.localizedDescription)")
            }
        }
    }
     */
}
