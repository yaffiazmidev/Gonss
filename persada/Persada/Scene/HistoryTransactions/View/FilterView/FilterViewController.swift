//
//  FilterViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

enum JenisTransaksi: String {
    case debit = "DEBIT"
    case withdrawal = "CREDIT"
}

class FilterViewController: UIViewController, AlertDisplayer {

    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var withdrawalView: UIView!
    @IBOutlet weak var visualEffectBlur: UIVisualEffectView!
    @IBOutlet weak var uangMasukView: UIView!
    @IBOutlet weak var uangMasukLabel: UILabel!
    @IBOutlet weak var penarikanView: UIView!
    @IBOutlet weak var penarikanLabel: UILabel!
    
    let datePicker = UIDatePicker()
    
    var jenisTransaksi: JenisTransaksi = .debit {
        didSet {
            setupViewForTapped()
        }
    }
    var dateFrom: String?
    var dateTo: String?
    
    var passData: ((String, String, JenisTransaksi) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleTapToDismiss()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupDatePicker()
    }
    
    func setupView() {
        setupNavbar()
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        fromDateTextField.inputAccessoryView = toolbar
        fromDateTextField.inputView = datePicker
        toDateTextField.inputAccessoryView = toolbar
        toDateTextField.inputView = datePicker
    }
    
    func handleTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        visualEffectBlur.addGestureRecognizer(tap)
    }
    
    func setupViewForTapped() {
        switch jenisTransaksi {
        case .debit:
            uangMasukView.backgroundColor = UIColor(hexString: "E7F3FF")
            uangMasukLabel.textColor = UIColor(hexString: "1890FF")
            penarikanView.backgroundColor = UIColor(hexString: "FAFAFA")
            penarikanLabel.textColor = UIColor(hexString: "777777")
        case .withdrawal:
            uangMasukView.backgroundColor = UIColor(hexString: "FAFAFA")
            uangMasukLabel.textColor = UIColor(hexString: "777777")
            penarikanView.backgroundColor = UIColor(hexString: "E7F3FF")
            penarikanLabel.textColor = UIColor(hexString: "1890FF")
        }
    }
    
    func getInvalidAlertDate() {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: .get(.error), message: "Perhatikan Validasi Tanggal", actions: [action])
    }
    
    @objc func doneDatePicker(){
        if fromDateTextField.isFirstResponder {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            fromDateTextField.text = formatter.string(from: datePicker.date)
            dateFrom = fromDateTextField.text
            self.view.endEditing(true)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            toDateTextField.text = formatter.string(from: datePicker.date)
            dateTo = toDateTextField.text
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func kindOfTransactionPressed(_ sender: UIButton) {
        switch jenisTransaksi {
        case .debit:
            jenisTransaksi = .withdrawal
        case .withdrawal:
            jenisTransaksi = .debit
        }
    }
    
    @IBAction func applyButtonPressed(_ sender: Any) {
        guard let dateFrom = dateFrom, let dateTo = dateTo, dateFrom.toDate() <= dateTo.toDate(), dateFrom.toDate() <= Date(), dateTo.toDate() <= Date() else {
            getInvalidAlertDate()
            return
        }
        
        let threeMonthsLater = Date().removeMonths(numberOfMonths: 3)
        
        if dateFrom.toDate() >= threeMonthsLater && dateTo.toDate() >= threeMonthsLater {
            passData?(dateFrom, dateTo, jenisTransaksi)
            dismissView()
            return
        }
        getInvalidAlertDate()
    }
}
