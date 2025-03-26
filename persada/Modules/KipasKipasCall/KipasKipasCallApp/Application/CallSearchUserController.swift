//
//  CallSearchUserController.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import KipasKipasCall

class CallSearchUserController: UIViewController {
    
    private let mainView: CallSearchUserView
    var delegate: ProfileDelegate?
    
    var didSelectUser: ((CallProfile) -> Void)?
    
    var data: [CallProfile]?
    
    init() {
        mainView = CallSearchUserView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension CallSearchUserController {
    func setupView() {
        mainView.textField.delegate = self
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    func searchUser(query: String?) {
        guard let query = query else { return }
        
        view.endEditing(true)
        
        if query.isEmpty {
            DispatchQueue.main.async {
                self.mainView.showEmpty(true, message: "Search User Target")
                self.mainView.showLoading(false)
                self.mainView.showTable(false)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.mainView.showLoading(true)
            self.mainView.showEmpty(false)
            self.mainView.showTable(false)
        }
        
        delegate?.didProfileSearch(username: query) { [weak self] (profiles, message) in
            guard let self = self else { return }
            
            self.data = profiles
            DispatchQueue.main.async {
                self.mainView.showLoading(false)
                
                if let message = message {
                    self.mainView.showEmpty(true, message: message)
                    return
                }
                
                if profiles?.isEmpty ?? true {
                    self.mainView.showEmpty(true, message: "Users not found")
                    return
                }
                
                self.mainView.showEmpty(false)
                self.mainView.showTable(true)
                self.mainView.tableView.reloadData()
            }
        }
    }
}

extension CallSearchUserController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchUser(query: textField.text)
        return true
    }
}

extension CallSearchUserController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = data?[indexPath.row]
        dismiss(animated: true) {
            if let user {
                self.didSelectUser?(user)
            }
        }
    }
}

extension CallSearchUserController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainView.tableView.dequeueReusableCell(withIdentifier: "CallSearchUserCell", for: indexPath) as! CallSearchUserCell
        cell.setup(profile: data![indexPath.row])
        return cell
    }
}
