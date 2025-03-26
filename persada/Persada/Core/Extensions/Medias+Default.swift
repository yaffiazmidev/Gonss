//
//  Medias+Default.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

extension Medias {
	static func toMedias() -> Medias {
		return Medias (
			id: "",
			type: "image", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703.png",
			thumbnail: Thumbnail(
				large: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_984x984.png",
				medium: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_656x656.png",
				small: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_328x328.png"
			),
			metadata: Metadata(
				width: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_984x984.png",
				height: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_656x656.png",
				size: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/tmp/media/1615945213703_328x328.png"
			))
	}
}

extension ResponseMedia {
    func toMedias() -> Medias {
        return Medias(
            id: self.id, type: self.type, url: self.url, thumbnail: self.thumbnail, metadata: self.metadata
        )
    }
}
