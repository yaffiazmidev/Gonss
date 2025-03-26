//
//  AppDelegate+URLSchemes.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/11/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasShared

fileprivate var timer: Timer?

extension AppDelegate {
    func configureURLSchemesFeature() {
        URLSchemes.instance.delegate = self
    }
    
    func urlSchemesOpenPostMedias(with params: Dictionary<String, String>) {
        guard !params.isEmpty else { return }
        
        guard let encodedPaths = params["paths"],
              let decodedPaths = encodedPaths.removingPercentEncoding,
              let dataPaths = decodedPaths.data(using: .utf8),
              let paths = try? JSONSerialization.jsonObject(with: dataPaths, options: []) as? [String: [String]],
              let photos = paths["photos"],
              let videos = paths["videos"]
        else { return }
        
        var medias: [KKMediaItem] = []
        for photo in photos {
            if let url = URL(string: photo), let item = KKMediaHelper.instance.photo(url: url) {
                medias.append(item)
            }
        }
        
        if videos.isEmpty {
            showPostController(medias)
            return
        }
        
        var videosProcessedCount = 0
        KKLoading.shared.show()
        for video in videos {
            guard let url = URL(string: video) else {
                videosProcessedCount += 1
                return
            }
            KKMediaHelper.instance.video(url: url) { [weak self] (item, message) in
                videosProcessedCount += 1
                guard let self = self, let item = item else {
                    KKLogFile.instance.log(label:"urlSchemesOpenPostMedias", message: "Error: \(message ?? "")", level: .error)
                    return
                }
                medias.append(item)
                
                if videosProcessedCount >= videos.count {
                    DispatchQueue.main.async {
                        KKLoading.shared.hide()
                        self.showPostController(medias)
                    }
                }
            }
        }
        
    }
    
    func showPostController(_ medias: [KKMediaItem]) {
        guard let activeController = window?.topViewController,
              let firstController: UIViewController? = controller(from: activeController),
              let mainTabController = firstController?.tabBarController as? MainTabController
        else { return }
        
        if !AUTH.isLogin(){
            mainTabController.showPopUp()
            return
        }
        
        var dataSource = PostModel.DataSource()
        dataSource.itemMedias = medias
        mainTabController.postController = PostController(mainView: PostView(isCreateFeed: true), dataSource: dataSource)
        mainTabController.postController?.onPostClickCallback = { postParam in
            mainTabController.uploadDelegate.onUploadCallBack(param: postParam)
            mainTabController.postController?.dismiss(animated: true)
        }
        
        guard let controller = mainTabController.postController else { return }
        let navigate = UINavigationController(rootViewController: controller)
        navigate.modalPresentationStyle = .fullScreen
        activeController.present(navigate, animated: true, completion: nil)
    }
    
    func controller<T>(from controller: UIViewController) -> T? {
        return controller.navigationController?.viewControllers
            .compactMap { $0 as? T }
            .first
    }
}

extension AppDelegate: URLSchemesDelegate {
    func didReceive(with data: URLSchemesQuery) {
        if data.query == "postMedias" {
            urlSchemesOpenPostMedias(with: data.data)
            return
        }
    }
}
