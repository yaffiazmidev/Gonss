//
//  BalanceMianView.swift
//  KipasKipasDirectMessageUI
//
//  Created by admin on 2024/4/7.
//

import Foundation
import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol BalanceMianViewDelegate: AnyObject {
    func didTapCoinPurchase()
    func didTapDiamondWithdrawal()
    func didTapShowMsg()
    func didTapVerifyButton()
    func didTapVerifyCard()
    func didTapViewBalance()
}

class BalanceMianView:UIView {
    
    weak var delegate: BalanceMianViewDelegate?
    @IBOutlet weak var topTitleL: UILabel!
    
    @IBOutlet weak var rewardsView: UIView!
    
    @IBOutlet weak var liveIdrNumLabel: UILabel!
    
    @IBOutlet weak var coinNumLabel: UILabel!
    @IBOutlet weak var dmDiamondNumLabel: UILabel!
    
    @IBOutlet weak var levelImgV: UIImageView!
    @IBOutlet weak var levelNumLabel: UILabel!
    
    
    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var diamondView: UIView!
    @IBOutlet weak var verifyView: UIView!
    
    @IBOutlet weak var transactionsView: UIView!
    @IBOutlet weak var identityView: UIView!
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var lackLabel: UILabel!
    
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var viewBalanceContainerStack: UIStackView!
    
    @IBOutlet weak var viewBalanceView: UIView!
    var data:RemoteBalanceCurrencyDetail? = nil {
        didSet{
            self.liveIdrNumLabel.text = "\(data?.idrLiveAmount ?? 0)"
            self.coinNumLabel.text = " \(data?.coinAmount ?? 0)"
            self.dmDiamondNumLabel.text = "\(data?.diamondAmount ?? 0)" 
            
            KKCache.common.save(integer: data?.coinAmount ?? 0, key: .coin)
            KKCache.common.save(integer: data?.diamondAmount ?? 0, key: .diamond)
            KKCache.common.save(integer: data?.liveDiamondAmount ?? 0, key: .liveDiamondAmount)
            
            let verifIdentityStatus = data?.verifIdentityStatus ?? "unverified"
            
            verifiedLabel.isHidden = true
            verifyView.isHidden = true
            print("[AZMI] - \(data?.verifIdentityStatus ?? "")")
            switch data?.verifIdentityStatus ?? "unverified" {
            case "unverified":
                verifyView.isHidden = false
//            case "uploaded":
//                
//            case "checking", "validating", "waiting_verification":
//                
            case "verified":
                verifiedLabel.isHidden = false
            case "rejected":
                verifyView.isHidden = false
            case "revision":
                verifyView.isHidden = false
            default:
                break
            }
            
        }
    }
    
    var gradedata:RemoteBalancePointsData? = nil {
        didSet{
            self.levelNumLabel.text = "\(gradedata?.consumptionGrade ?? 0)"
            self.lackLabel.text = "\(gradedata?.lackPoints ?? 0) more experience points to level up"
            
            KKCache.common.save(integer: gradedata?.consumptionGrade ?? 0, key: .consumptionGrade)
            KKCache.common.save(integer: gradedata?.lackPoints ?? 0, key: .lackPoints)
            
            var consumptionGrade = gradedata?.consumptionGrade ?? 1
            if consumptionGrade > 6 {
                consumptionGrade = 6
            }
            let imgName = "ic-balance-min\(consumptionGrade)"
            self.levelImgV.image = .set(imgName)
             
        }
    }
      
    
    override func awakeFromNib() {
           super.awakeFromNib()
        
        setupFont()
        setInitData()
        
        setupAction()
        
        
    }
    
    @IBAction func verifyAction() {
        self.delegate?.didTapVerifyButton()
    }
    
    func setupFont(){ 
        self.topTitleL.lineBreakMode = .byTruncatingMiddle
    }
    
    func setupAction(){
        
        rewardsView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapShowMsg()
            }
        }
        
        coinView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapCoinPurchase()
            }
        }
        
        diamondView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapDiamondWithdrawal()
            }
        }
        
        transactionsView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapShowMsg()
            }
        }
        
        identityView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapVerifyCard()
            }
        }
        helpView.onTap { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didTapShowMsg()
            }
        }
        
        let onTapViewBalance = UITapGestureRecognizer(target: self, action: #selector(handleTapViewBalance))
        viewBalanceView.isUserInteractionEnabled = true
        viewBalanceView.addGestureRecognizer(onTapViewBalance)
    }
    
    @objc func handleTapViewBalance() {
        delegate?.didTapViewBalance()
    }
    
    func setInitData(){
        let name = UserDefaults.standard.object(forKey: "name")
        if let oldName = name as? String ,oldName.count > 0 {
            self.topTitleL.text =  oldName
        }else{
            let username = UserDefaults.standard.object(forKey: "username")
            if let uName = username as? String  {
                self.topTitleL.text =  uName
            }
        }
//        let coin = KKCache.common.readInteger(key: .coin) ?? 0
//        let diamond = KKCache.common.readInteger(key: .diamond) ?? 0
//        let idrAmount = KKCache.common.readDouble(key: .idrAmount) ?? 0
        
        var consumptionGrade = KKCache.common.readInteger(key: .consumptionGrade) ?? 0
        let lackPoints = KKCache.common.readInteger(key: .lackPoints) ?? 0
        
         
//        self.coinNumLabel.text = "\(coin)"
        
        self.levelNumLabel.text = "\(consumptionGrade)"
        self.lackLabel.text = "\(lackPoints) more experience points to level up"
        
        if consumptionGrade > 6 {
            consumptionGrade = 6
        }
        let imgName = "ic-balance-min\(consumptionGrade)"
        self.levelImgV.image = .set(imgName)
    }
    
}
